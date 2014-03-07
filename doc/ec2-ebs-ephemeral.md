http://www.webadminblog.com/index.php/2010/03/23/amazon-ec2-ebs-instances-and-ephemeral-storage/

Amazon EC2 EBS Instances and Ephemeral Storage

Here's a couple tidbits I've gleaned that are useful.

When  you start an "instance-store" Amazon EC2 instance, you get a certain amount of ephemeral storage allocated and mounted automatically.  The amount of space varies by instance size and is defined here.  The storage location and format also varies by instance size and is defined here.

The upshot is that if you start an "instance-store" small Linux EC2 instance, it automagically has a free 150 GB /mnt disk and a 1 GB swap partition up and runnin' for ya.  (mount points vary by image, but that's where they are in the Amazon Fedora starter.)

[root@domU-12-31-39-00-B2-01 ~]# df -k
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda1             10321208   1636668   8160252  17% /
/dev/sda2            153899044    192072 145889348   1% /mnt
none                    873828         0    873828   0% /dev/shm
[root@domU-12-31-39-00-B2-01 ~]# free
total       used       free     shared    buffers     cached
Mem:       1747660      84560    1663100          0       4552      37356
-/+ buffers/cache:      42652    1705008
Swap:       917496          0     917496
But, you say, I am not old or insane!  I use EBS-backed images, just as God intended.  Well, that's a good point.  But when you pull up an EBS image, these ephemeral disk areas are not available to you.  The good news is, that's just by default.

The ephemeral storage is still available and can be used (for free!) by an EBS-backed image.  You just have to set the block devices up either explicitly when you run the instance or bake them into the image.

Runtime:

You refer to the ephemeral chunks as "ephemeral0", "ephemeral1", etc. - they don't tell you explicitly which is which but basically you just count up based on your instance type (review the doc).  For a small image, it has an ephemeral0 (ext3, 15 GB) and an ephemeral1 (swap, 1 GB).  To add them to an EBS instance and mount them in the "normal" places, you do:

ec2-run-instances <ami id> -k <your key> --block-device-mapping '/dev/sda2=ephemeral0'
--block-device-mapping '/dev/sda3=ephemeral1'
On the instance you have to mount them - add these to /etc/fstab and mount -a or do whatever else it is you like to do:

/dev/sda3                 swap                    swap    defaults 0 0
/dev/sda2                 /mnt                    ext3    defaults 0 0
And if you want to turn the swap on immediately, "swapon /dev/sda3".

Image:

You can also bake them into an image.  Add a fstab like the one above and when you create the image, do it like this, using the exact same --block-device-mapping flag:

ec2-register -n <ami id> -d "AMI Description" --block-device-mapping  /dev/sda2=ephemeral0
--block-device-mapping '/dev/sda3=ephemeral1' --snapshot your-snapname --architecture i386
--kernel<aki id>  --ramdisk <ari id>
Ta da. Free storage that doesn't persist.  Very useful as /tmp space.  Opinion is split among the Linuxerati about whether you want swap space nowadays or not; some people say some mix of  "if you're using more than 1.8 GB of RAM you're doing it wrong" and "swapping is horrid, just let bad procs die due to lack of memory and fix them."  YMMV.

Ephemeral EBS?

As another helpful tip, let's say you're adding an EBS to an image that you don't want to be persistent when the instance dies.  By default, all EBSes are persistent and stick around muddying up your account till you clean them up.   If you don't want certain EBS-backed drives to persist, what you do is of the form:

ec2-modify-instance-attribute --block-device-mapping "/dev/sdb=vol-f64c8e9f:true" i-e2a0b08a
Where 'true' means "yes, please, delete me when I'm done."  This command throws a stack trace to the tune of

Unexpected error: java.lang.ClassCastException: com.amazon.aes.webservices.client.InstanceBlockDeviceMappingDescription
cannot be cast to com.amazon.aes.webservices.client.InstanceBlockDeviceMappingResponseDescription
But it works, that's just a lame API tools bug.

Tagged as: amazon, aws, ebs, ec2, ephemeral, image, storageLeave a comment
Comments (10)Trackbacks (3)( subscribe to comments on this post )
 Victor Trac
March 23rd, 2010 - 20:24
One of the tricks that I’ve learned is to go ahead and “bake in” all 4 ephemeral disks in your EBS-backed images, regardless if they’re i386 or x86_64. That way, you’ll get the maximum number of ephemeral disks allocated to your instance size (up to 4x450GB on c1.xlarge instances).
Ernest
March 24th, 2010 - 10:20
That’s a good idea. Do you use that space for anything? I’m kinda adding it “just in case”, but I’m using EBS for a) data, for persistence and b) software, so it can be easily mounted up.
Victor Trac
March 24th, 2010 - 15:42
EBS performance can be pretty bad at times, so for long running tasks, we use the ephemeral disks in RAID0 configuration. Our scripts create a new server, builds a RAID0 array of 4 ephemeral disks, and then copies the data from an EBS to the RAID array before launching the job. Even with the copy time, it ends up being faster for long running jobs.
Ernest
March 24th, 2010 - 17:12
Interesting, I thought EBS was supposedly faster then ephemeral! Cool.
Hey question, I liked what you said about the adding the other drives just in case but I’m trying that and I’m having trouble at boot… How are you doing it?
Ernest
March 25th, 2010 - 08:52
Ah, NM, it was trying to fsck the absent disks. It took like 15 minutes for the boot process to die and show the errors.
Hey, have you noticed that every day starting at about 4 PM all the Amazon operations – snapshotting, creating images, etc. – get super duper slow? What’s up with that? It’s pretty fast throughout the day, but right around end of day it gets intolerable.
Joshua
March 30th, 2010 - 00:00
Can you give any more detail on ‘count up’ the ids? I’m trying to launch an m1.large as a test, and I can’t find the right combinations of devices and ephemeral stores.
Ernest
March 30th, 2010 - 10:05
Sure. From the second linked doc it looks to me like a large UNIX instance has an ephemeral slated for /dev/sdb and /dev/sdc, at least those are the ones listed with a m1.large on ‘em. So the first one is probably ephemeral0 and the second ephemeral1. So I do this:
C:\Program Files>ec2-run-instances ami-86db39ef -k services-dev -b “/dev/sdb=ephemeral0″ -b “/dev/sdc=ephemeral1″ -t m1.large
And when it comes up, they are there – I mount up /dev/sdb and /dev/sdc and do a df -T; looks like they’re both ext3 and 425GB or so in size, which jives with the “850 GB” that the instance type matrix (first linked doc) mentions. I don’t think there’s any way to reclaim what would have been the 10 GB root partition.
I agree it’s confusing; if Amazon thought about their docs a moment they’d make a little chart of the instance types with the available “ephemeralx” names in them for clarity.
I haven’t tried it, but so for example the high cpu XL instance notes it has 4 420 GB partitions, so they’d be ephemeral0, ephemeral1, ephemeral2, ephemeral3.
It doesn’t actually matter what device you mount them as. The ones listed are just the defaults they come on some of the stock instance-store instances as. You can do this and it works fine:
C:\Program Files>ec2-run-instances ami-86db39ef -k services-dev -b “/dev/sdf=ephemeral1″ -t m1.large
Joshua
March 30th, 2010 - 14:14
Thanks, that makes sense. I guess was thinking I could still link the swap as well.
RiskEraser
October 30th, 2010 - 15:10
FYI The new micro instances don’t have any ephemeral storage at all, your only option is to create another EBS volume to use as swap space.
Chris Fordham
August 7th, 2011 - 01:53
@RiskEraser
You can use an AMI which has a built-in swap partition or simply use a swap file on the root filesystem/partition.