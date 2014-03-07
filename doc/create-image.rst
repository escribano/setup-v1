 http://alestic.com/2009/06/ec2-ami-bundle.

Creating a New Image for EC2 by Rebundling a Running Instance

By Eric Hammond on June 29, 2009 10:31 AM | 29 Comments | 3 TrackBacks
NOTE: This is an article from 2009, back before EBS boot instances were available on Amazon EC2. I recommend you use EBS boot instances which make it trivial to create new AMIs (single command/API call). Please stop reading this article now and convert to EBS boot AMIs!

When you start up an instance (server) on Amazon EC2, you need to pick the image or AMI (Amazon Machine Image) to run. This determines the Linux distribution and version as well as the initial software installed and how it is configured.

There are a number of public images to choose from with EC2 including the Ubuntu and Debian image published on http://alestic.com but sometimes it is appropriate to create your own private or public images. There are two primary ways to create an image for EC2:

Create an EC2 image from scratch. This process lets you control every detail of what goes into the image and is the easiest way to automate image creation.

Rebundle a running EC2 instance into a new image. This approach is the topic of the rest of this article.

After you rebundle a running instance to create a new image, you can then run new EC2 instances of that image. Each instance starts off looking exactly like the original instance as far as the files on the disk go (with a few exceptions).

This guide is primarily written in the context of running Ubuntu on EC2, but the concepts should apply without too much changing on Debian and other Linux distributions.

To use this rebundling approach, you start by running an instance of an image that (1) is as close as possible to the image you want to create, and (2) is published by a source you trust. You then proceed to install software and configure that instance so that it contains exactly what you want to be available on new instances right down to the startup scripts.

The next step is to bundle the instance’s disk image into a new AMI, but before we get to that, it is important to understand a few things about security.

Security

If you are creating a new EC2 image, you need to be very careful what pieces of information you inadvertently leave on the image, especially if you have the goal of publishing it as a public AMI. Anybody who runs an instance of that AMI will have access to the files you included in the bundle, and there is no way to modify an AMI after it has been created (though you can delete it).

For example, you don’t want to leave your AWS certificate or private key on the disk. You’ll even want to clear out the shell history file in case you had typed secret information in commands or in setting environment variables.

You also want to consider the security concerns from the perspective of the people who run the new image. For example, you don’t want to leave any passwords active on accounts. You should also make sure you don’t include your public ssh key in authorized_keys files. Leaving a back door into other people’s servers is in poor taste even if you have no intention of ever using it.

Here are some sample commands, but only you can decide if this wipes out too much or what other files you need to exclude depending on how you set up and used the instance you are bundling:

sudo rm -f /root/.*hist* $HOME/.*hist*
sudo rm -f /var/log/*.gz
sudo find /var/log -name mysql -prune -o -type f -print | 
  while read i; do sudo cp /dev/null $i; done
Whole directories can be excluded from the image using the --exclude option of the ec2-bundle-vol command (see below).

Rebundling

Now we’re ready to bundle the actual EC2 image (AMI). To start, you need to copy your certificate and key to the instance ephemeral storage. Adjust the sample command to use the appropriate keypair file for authentication and the appropriate location of your certification and private key files. If you are not running a modern Ubuntu image, then change remoteuser to “root”.

remotehost=<ec2-instance-hostname>
remoteuser=ubuntu

rsync                             --rsh="ssh -i KEYPAIR.pem"       --rsync-path="sudo rsync"      PATHTOKEYS/{cert,pk}-*.pem      $remoteuser@$remotehost:/mnt/
Set up some environment variables for convenience in the following commands. A single S3 bucket can be used for multiple AMIs. The manifest prefix should be descriptive, especially if you plan to publish the AMI publicly, as it is the only piece of documentation many users will see when they look through AMI lists. At a minimum, I recommend including the Linux distribution (e.g, “ubuntu”), the architecture (e.g., “i386” or “32”), and the date (e.g., “20090621”), as well as some tag that indicates the special nature of the image (e.g., “desktop” or “lamp”).

bucket=<your-bucket-name>
prefix=<descriptive-image-title>
On the EC2 instance itself, you also set up some environment variables to help the bundle and upload commands. You can find these values in your EC2 account.

export AWS_USER_ID=<your-value>
export AWS_ACCESS_KEY_ID=<your-value>
export AWS_SECRET_ACCESS_KEY=<your-value>

if [ $(uname -m) = 'x86_64' ]; then
  arch=x86_64
else
  arch=i386
fi
Bundle the files on the current instance into a copy of the image under /mnt:

sudo -E ec2-bundle-vol             -r $arch                         -d /mnt                          -p $prefix                       -u $AWS_USER_ID                  -k /mnt/pk-*.pem                 -c /mnt/cert-*.pem               -s 10240                         -e /mnt,/root/.ssh,/home/ubuntu/.ssh
Upload the bundle to a bucket on S3:

ec2-upload-bundle                    -b $bucket                       -m /mnt/$prefix.manifest.xml     -a $AWS_ACCESS_KEY_ID            -s $AWS_SECRET_ACCESS_KEY
Now that the AMI files have been uploaded to S3, you register the image as a new AMI. This is done back on your local system (with the API tools installed):

ec2-register   --name "$bucket/$prefix"   $bucket/$prefix.manifest.xml
The output of this command is the new AMI id which is used to run new instances of that image.

It is important to use the same account access information for the ec2-bundle-vol and ec2-register commands even though they are run on different systems. If you don’t you’ll get an error indicating you don’t have the rights to register the image.

Public Images

By default, the new EC2 image is private, which means it can only be seen and run by the user who created it. You can share access with another individual account or with the public.

To let another EC2 user run the image without giving access to the world:

ec2-modify-image-attribute -l -a <other-user-id> <ami-id>
To let all other EC2 users run instances of your image:

ec2-modify-image-attribute -l -a all <ami-id>
Cost

AWS will charge you standard S3 charges for the stored AMI files which comes out to $0.15 per GB per month. Note, however, that the bundling process uses sparse files and compression, so the final storage size is generally very small and your resulting cost may only be pennies per month.

The AMI owner incurs no charge when users run the image in new instances. The users who run the AMI are responsible for the standard hourly instance charges.

Cleanup

Before removing any public image, please consider the impact this might have on people who depend on that image to run their business. Once you publish an AMI, there is no way to tell how many users are regularly creating instances of that AMI and expecting it to stay available. There is also no way to communicate with these users to let them know that the image is going away.

If you decide you want to remove an image anyway, here are the steps to take.

Deregister the AMI

ec2-deregister ami-XXX
Delete the AMI bundle in S3:

ec2-delete-bundle   --access-key $AWS_ACCESS_KEY_ID   --secret-key $AWS_SECRET_ACCESS_KEY   --bucket $bucket   --prefix $prefix
[Update 2009-09-12: Security tweak for running under non-root.] [Update 2010-02-01: Update to use latest API/AMI tools and work for Ubuntu 9.10 Karmic.]

Categories:

EC2,
PlanetUbuntu,
Ubuntu,
UbuntuCloud
Tags:

AMI,
AMIs,
building,
bundling,
EC2,
guide,
image,
images,
tutorial,
Ubuntu
3 TrackBacks

TrackBack URL: http://alestic.com/mt/mt-tb.cgi/37

esh's status on Monday, 29-Jun-09 10:53:52 PDT from esh on June 29, 2009 9:54 AM
Notes on creating a new EC2 image by rebundling a running instance: http://alestic-rebundle.notlong.com Read More

rebundling an ec2 ami from Confluence: Project - MasterCard on November 4, 2009 9:06 AM
most of what I got is lifted from here Read More

Developing Images on Eucalyptus from Confluence: Clouds on January 8, 2010 12:42 PM
This will be in quick note form for now. Reference these docs: Read More

29 Comments

  jmk226.myopenid.com | July 3, 2009 2:29 PM | Reply
Excellent information. I'm preparing to release several AMIs based on my work with Chapter Three in developing ready-to-go installations of the Drupal CMS (and associated stack) for clients. Will keep this on file before I send anything out.

Now that AWS is offering reserved instances at extremely competitive prices, with the right backup and restore structure it's possible to deliver really great value for clients who are ready to take the leap into the cloud.

One question, given that there's no way to update an AMI, what's your recommended process for versioning releases? Most alestic AMI's come with a datestamp, which is great, but how do you keep track of all this internally?

Anyway, I have to tip my hat to you, sir. Without this kind of trailblazing work (and all the free AMIs from alestic) none of my contributions would be possible.

  frickenate | October 19, 2009 7:02 AM | Reply
My problem with learning how to bundle or rebundle is that there are no docs *anywhere* I can find that provide enough details about what to include and not include. It's a nightmare trying to figure out how the basics of bundling work, let alone trying to hammer out how to deal with the Alestic layer applied on top of it in order to accomplish a rebundle.

1. For bundling, the default list of directories excluded by ec2-bundle-vol includes /dev. Does one really not need to include this? Will Amazon automatically create a /dev directory and fill it with all necessary devices (/dev/null, /dev/random, /dev/zero)? If /dev needs to be bundled, does bundling actually manage to correctly "copy" special devices like /dev/random, and won't bundling /dev include all the harddrive mount sources (/dev/sda1, etc), which would conflict with the separate block device config given to ec2-bundle-vol?

2. From the point of view of Alestic rebundling: how to make sure that the bundled image will start over "fresh", including Alestic startup script(s)? Specific example is that after rebundling, my rebundled AMI must be capable of using the Alestic functionality for executing the userdata script on first boot of all instances.

3. Finally, what about the creation/population of /root/authorized_keys? Is that something that an Alestic-included script does, or is that something Amazon does in the underlying instance launching? And if it's Amazon, is it done via a first-boot script I can locate on the filesystem, or does Amazon create that file from outside the OS (perhaps by the VM layer manually mounting the drive to create it).

Add on the fact that the kernel is somehow magically located external to the actual filesystem via the VM layer, and the confusion just continues. :|

  Eric Hammond replied to comment from frickenate | October 20, 2009 1:36 AM | Reply
frickenate: I'm confused about why you have so many questions about rebundling after reading an article which describes exactly how to rebundle. Why not try the steps listed, review the results, and then post questions you have? The best forum for general EC2 questions is the Amazon EC2 forum.

  robbucci | November 7, 2009 11:05 AM | Reply
Eric,

First off, thanks for all your hard work...I use a few different AMI's that you have put together and I really appreciate it.

I have been rebundling your AMI's following the steps you've outlined above, but I've run into an issue I'm hoping you can shed some light on for me..

when I rebundle an AMI and launch a new instance from it, none of the user-data scripts are run....I can confirm this by checking in the syslog...I went a step further and setup a script to be run at startup in init.d/ as outlined here:
http://snippets.dzone.com/posts/show/6200

But again, this script doesnt run when i rebundle the AMI and launch a new instance from it.


Do you have any pointers?

Thanks!
R

  Eric Hammond replied to comment from robbucci | November 7, 2009 7:22 PM | Reply
robbucci: The fact that your init.d script is not running implies that the problem is deeper than the user-data script itself.

  dipak.chirmade | November 25, 2009 2:32 AM | Reply
@Eric, Nice article! 
@Robbucci, I'm also facing the same problem while re-bundling eucalyptus images (Ubuntu). Whenever I'm running my user-scripts with originally bundled images, it worked but re-bundling as mentioned with this article as well as scripts given by UEC [ https://help.ubuntu.com/community/UEC/BundlingImages ], never worked for me. I think it is access-permission-issue for user-script to run in super-user mode. Not sure though!

Cheers,
Dipak Chirmade

  hughperkins.myopenid.com | December 1, 2009 6:46 PM | Reply
Eric,

First, your website is *awesome*. The is sooo much good concise perfectly-working information here. Lots of signal. Very little noise. Except for this paragraph you're reading right now perhaps :-P

My question: the new Canonical Karmic amis come with euca2ools instead of ami tools. The euca2ools are muuuch faster than Amazon's ec2 tools, though they feel a little beta, but: have you tried rebundling karmic using them? Could you get an instance to start from the resulting image afterwards? I found I could bundle easily enough, register the image, but starting the image using ec2-run-instances, the image looked like it was starting, and then immediately terminated. Ideas?
  Eric Hammond | December 2, 2009 3:21 AM | Reply
hughperkins: euca2ools is faster than the API tools, but not the AMI tools given the different type of work they are doing. That aside, I haven't been able to use euca2ools to bundle/upload/register successfully yet due to a bug. You can install the ec2-ami-tools package on Karmic (multiverse) and use them instead.

  pwolanin | February 1, 2010 9:15 AM | Reply
Above you suggest running the EXPORT for the secret access key right before bundling

But - that will leave it in the ubuntu user history I think. So, clearing the shell history should be the last step before bundling.

  pwolanin | February 1, 2010 9:45 AM | Reply
In the latest version of the ec2 API tolls (ec2-api-tools-1.3-46266), at least, the ec2-register command also seems to require the name (-n) parameter to be passed in.

  pwolanin | February 1, 2010 10:38 AM | Reply
Following these instruction I hit a minor snag with the new instance, the /tmp dir is only writable by root, so commands like "crontab -e" fail.

on the original instance:

drwxrwxrwt 6 root root 4096 2010-02-01 18:20 tmp

on the instance booted from the bundled AMI:

drwxr-xr-x 4 root root 4096 2010-02-01 18:21 tmp

obviously this is easy to fix manually, but is there something missing from the bundling process or the firstboot script?

  Eric Hammond replied to comment from pwolanin | February 1, 2010 11:13 AM | Reply
pwolanin: As I point out under "SECURITY", you have to be careful not to leave any private information on an AMI if you are going to make it public and clearing the history is one part of that. Each publisher will need to evaluate their own case and take the necessary steps.

If you are going to make an AMI public, for security and general image freshness I recommend building it from scratch instead of rebundling a running instance. Here are a couple articles about that:

http://alestic.com/2010/01/ec2-ebs-boot-ubuntu
http://alestic.com/2010/01/vmbuilder-ebs-boot-ami

Thanks also for pointing out the -n parameter. I'll take another run through the tutorial and update it.

  Eric Hammond | February 1, 2010 11:24 AM | Reply
pwolanin: The AMIs I built and published under the "alestic" name included a startup trigger which set up /tmp with the correct permissions. The Canonical (e.g., Karmic) AMIs do not have this, so you may not want to exclude (-e) the /tmp directory when bundling. I'll take it out of the example commands.

  pwolanin | February 1, 2010 6:11 PM | Reply
interestingly - on 9.10 at least, I had to use "history -c
" to clear my history (not sure where it's being stored). The commands above cleared what's in my home directory, but various private keys were still visible.

Also, the .pem uploads should go to /mnt not /tmp if that's no longer in the -e list.

e.g.
scp -i KEYPAIR.pem \
/{cert,pk}-*.pem \
$remoteuser@$remotehost:/mnt


and then:

/tmp/cert-*.pem --> /mnt/cert-*.pem

  Eric Hammond replied to comment from pwolanin | February 2, 2010 12:11 AM | Reply
pwolanin: History is stored in $HOME/.bash_history (eventually). I've updated the commands to work with the latest Ubuntu 9.10 Karmic AMI as a base, and the latest API/AMI tools. Thanks again for your testing and feedback.

  pwolanin | February 9, 2010 1:04 PM | Reply
Trying to launch an instance rebundled this way - I'm seeing what looks like the Ubuntu "can't ssh" bug re-appearing.

If I rebundle an instance does the original first boot script get restored and used, or is there another step needed to make that happen, or is some generic one from AWS used?
  Eric Hammond replied to comment from pwolanin | February 9, 2010 1:49 PM | Reply
pwolanin: For support, please use http://groups.google.com/group/ec2ubuntu/ and provide enough information for somebody else to reproduce it (e.g., AMI id, rebundle instructions, ssh error).

  victorchurchill | February 24, 2010 10:25 AM | Reply
Eric,
first, it has been said before but I add myself to those offering kudos and appreciation for this resource.

I am quite new to this and have encountered something I havn't seen mentioned.

My colleague has an instance in the U.S. and one that I am working on in the eu-west-1 region.
When I installed the EC2 commandline tools on the server and said ec2-describe-instances I saw the US instance.
I did 
export EC2_URL=https://ec2.eu-west-1.amazonaws.com
and the Europe instance was then shown instead. In the same shell session I ran the ec2-bundle-vol successfully. When I went on to ec2-upload-bundle I was told

You are bundling in one region, but uploading to another. If the kernel
or ramdisk associated with this AMI are not in the target region, AMI
registration will fail.
You can use the ec2-migrate-manifest tool to update your manifest file
with a kernel and ramdisk that exist in the target region.
Are you sure you want to continue? [y/N]

I ran
ec2-migrate-manifest \
-c /root/.ec2/cert-xxxxxxxxxxxxxxxxxx.pem \
-k /root/.ec2/pk-xxxxxxxxxxxxxxx.pem \
-m /mnt/image1/local_mysql.manifest.xml \
-a QWERTYUIOPZZZZZZZZ
--region eu-west-1

got
Successfully migrated /mnt/image1/local_mysql.manifest.xml
It is now suitable for use in eu-west-1.

But still get the warning. The bundle command is
root@ip-10-224-99-999:~# ec2-upload-bundle \
> -b someName \
> -m /mnt/image1/local_mysql.manifest.xml \
> -a QWERTYUIOPZZZZZZZZ \
> -s secret-squirrel

I am thinking maybe the account identifier is associated with the US instance - is there a way I can find that out?
Presumably for a proof-of-concept we could go ahead and upload+register the image anyway, it's "just" that it would have to hop over the Atlantic if we tried to launch an instance of it in the EU?

  Eric Hammond replied to comment from victorchurchill | February 24, 2010 4:05 PM | Reply
victor: I use ec2-migrate-bundle to migrate an image already registered in S3. For more in depth help, you might try the EC2 forum or ec2ubuntu Google group.

  victorchurchill | February 25, 2010 6:43 AM | Reply
googling around, it's not an unknown problem. Re-running the ec2-upload-bundle command specifying the parameter "--location EU" seems to fix the issue.
Thanks.
  aakashd | May 6, 2010 2:38 AM | Reply
Eric,
It was a very good post and quite extensive, except one thing that the init file on already running instance needs to be touched.

If file "/var/ec2/firstrun" exists on an instance, setup script "/etc/init.d/ec2-setup" is executed when instance is started for the first time. This script will remove the firstrun file, so script is not executed every time, instance is rebooted.

So, before creating AMI, we need to touch the file, and after the process is complete remove it. Else the instance will not be setup making it inaccessible.

  gordon | June 9, 2010 7:09 AM | Reply
thanks man for this great tutorial. saved me probably a few days of frustration.

  VisualFox | January 24, 2011 5:33 PM | Reply
Thank you for this great tutorial.

ec2-register asked me for my key and certificate:


ec2-register --name "$bucket/$prefix" $bucket/$prefix.manifest.xml -K /mnt/pk-*.pem -C /mnt/cert-*.pem
  globalcookie | February 4, 2011 3:18 PM | Reply
When I run:
$ sudo ec2-bundle-vol -d /mnt/amis -k /mnt/ids/pk-*.pem -c /mnt/ids/cert-*.pem -u 123456789123 -r i386

I get the error:
ERROR: execution failed: "mkfs.ext3 -F /mnt/amis/image -U 2c567c84-20a1-44b9-a353-dbdcc7ae863b -L "

Here's the entire output:


Copying / into the image file /mnt/amis/image...

Excluding: 

	 /sys/kernel/debug

	 /sys/kernel/security

	 /sys

	 /var/log/mysql

	 /var/lib/mysql

	 /mnt/mysql

	 /proc

	 /dev/pts

	 /dev

	 /dev

	 /media

	 /mnt

	 /proc

	 /sys

	 /etc/udev/rules.d/70-persistent-net.rules

	 /etc/udev/rules.d/z25_persistent-net.rules

	 /mnt/amis/image

	 /mnt/img-mnt

1+0 records in

1+0 records out

1048576 bytes (1.0 MB) copied, 0.00273375 s, 384 MB/s

mkfs.ext3: option requires an argument -- 'L'

Usage: mkfs.ext3 [-c|-l filename] [-b block-size] [-f fragment-size]

	[-i bytes-per-inode] [-I inode-size] [-J journal-options]

	[-G meta group size] [-N number-of-inodes]

	[-m reserved-blocks-percentage] [-o creator-os]

	[-g blocks-per-group] [-L volume-label] [-M last-mounted-directory]

	[-O feature[,...]] [-r fs-revision] [-E extended-option[,...]]

	[-T fs-type] [-U UUID] [-jnqvFKSV] device [blocks-count]

ERROR: execution failed: "mkfs.ext3 -F /mnt/amis/image -U 2c567c84-20a1-44b9-a353-dbdcc7ae863b -L "

  Eric Hammond replied to comment from globalcookie | February 5, 2011 12:00 AM | Reply
globalcookie:

Looks like ec2-bundle-vol is not passing a label to mkfs.ext3.

Now that we have EBS boot instances, I no longer use the rebundling method described in this article. I recommend using and creating EBS boot AMIs instead as they offer a lot of advantages including making it much easier to create new images from running instances.

  globalcookie replied to comment from Eric Hammond | February 6, 2011 11:33 PM | Reply
Eric,

Thanks so much for the response, and I totally agree with your ideaology.

I'm using an AMI that is instance store, and the maker of the AMI hasn't released a EBS boot version...YET.

We have, however, created an EBS volume, attached and formatted it as /vol and moved our /var/www and MySQL data there.

This has worked for the past few months while we have been in development.

Last week our instance stopped responding. We contacted Amazon via the discussion forum, and found that there was an underlying hardware problem.

So we had to spin up a new instance with the aforementioned AMI, make our customizations to it and then re-attach the volume.

No big deal, and only a few hours lost re-customizing the AMI.

Now we want to minimize that "few hours" down to 5 or 10 minutes by re-bundling the AMI after we have made our customizations to it.

How would you recommend we get to where we want to be with the following:

AMI - instance store with most of the software/customization.

Running instance built on AMI with our own customization.

Desired result: EBS boot AMI of aforementioned AMI.

Any response would be appreciated. I realize that the answer may be too complicated to answer in a blog comment.

We have been reading alot about Amazon EC2 over the last 9 months and your name has come up significantly more than others. We solidly appreciate your work and advice.

  Eric Hammond replied to comment from globalcookie | February 7, 2011 2:59 PM | Reply
The basic approach to creating an EBS boot AMI is to create an EBS boot volume, copy your file system to it (rsync -PaSHAX), snapshot it, and register the EBS snapshot as a new AMI with the appropriate AKI and ARI. You can start with a downloaded image from Ubuntu, or the file system of a running EC2 instance. Further questions about this approach are suitable for more populated forums where others can pitch in with answers.

  Britton | May 3, 2011 12:25 PM | Reply
Thanks for the helpful instructions. Just a quick question--should an AMI upload to S3 take several hours? We've got a 193 part AMI uploading (10GB image of a 40GB EBS splits into 193 10 meg parts for some reason...) and it's taking far longer than a normal S3 transaction.

  Eric Hammond replied to comment from Britton | May 3, 2011 4:52 PM | Reply
Britton:

This is a very old article which talks about S3-based AMIs. I recommend using EBS boot AMIs instead as they make it trivial to create a new AMI from an instance and there are many other good reasons for using EBS boot instances.
