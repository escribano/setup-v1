http://www.bluetangstudio.com/2011/04/how-to-enable-ephemeral-storage-for.html

How to enable ephemeral storage on Amazon Beanstalk instance.
Amazon's Beanstalk is a great deployment environment for startup like us. Occasionally, we see issue on the beanstalk but lucky beanstalk allow us to use custom AMI for the beanstalk instances.

One of the issue we seen is that beanstalk only comes with 8GB ESB storage. But in fact, each EC2 instance comes with ephemeral(local) storages.(the size varies based on the instance type).

Our goal is to enable these missing ephemeral storage for the tomcat application. To do create a custom AMI with ephemeral storage.

I. Disable Auto Mount

Due to the default setting in CloudInit, it always mounts the first ephemeral drive on /media/ephemeral. To make the mountpoint customizable, we have to disable automount ephemeral0 first.

To do so, you have to launch a new instance with the beanstalk AMI first.
ec2-run-instances ami-b8c539d1 -t m1.large

Log in to the server
Edit /etc/sysconfig/cloudinit, and set CONFIG_MOUNTS=no.
Edit the /etc/fstab

/dev/sdb /var/cache/tomcat6 auto defaults 0 2
  /dev/sdc /tmp auto defaults 0 2
And then delete everything in /var/cache/tomcat6.

rm -rf /var/cache/tomcat6/*

II. Create a Temporary AMI

Log in to http://aws-portal.amazon.com and create a new AMI based on the instance we just used. 

III. Create the Cloud Init Script

Open your text editor and create a tomcat.init script on your local machine

#!/bin/sh

chown root:root /var/cache/tomcat6
chmod 755 /var/cache/tomcat6
chmod 1777 /tmp

if [ ! -d  /var/cache/tomcat6/temp ]
then 
  mkdir /var/cache/tomcat6/temp
  chmod 775 /var/cache/tomcat6/temp
  chown tomcat:root /var/cache/tomcat6/temp
fi
if [ ! -d  /var/cache/tomcat6/work ]
then 
  mkdir /var/cache/tomcat6/work
  chmod 775 /var/cache/tomcat6/work
  chown tomcat:root /var/cache/tomcat6/work
fi

IV. Create a New Instance with Ephemeral Storage
ec2-run-instances ami-xxxxxxx --user-data-file tomcat.init -b /dev/sdb=ephemeral0 -b /dev/sdc=ephemeral1 -t m1.large 

V. Create Beanstalk AMI


Log in to http://aws-portal.amazon.com and create a new AMI based on the instance we just initiated. This AMI is the AMI you can use in your beanstalk environment.
at Wednesday, April 27, 2011   
Email This
BlogThis!
Share to Twitter
Share to Facebook

2 comments:

SunnyMay 7, 2011 5:21 AM
Great post! I had the same basic need. All I wanted to do was be able to add an ephemeral storage to my beanstalk instance. So I ended up creating a custom ami (more or less identically to what you've described). After launching the environment with the custom ami, the instance comes up fine and I can log in to it and see the new ephemeral storage. But the problem is that Beanstalk complains that it can't check the status of the instance and eventually terminates the instance. I've also noticed that none of the services (apache, tomcat) were running on the instance. Any idea what might be causing this?

Thank you in advance!

SK.

Reply

MalkovichJune 29, 2011 12:34 PM
In your facebook picture, you mean "location-aware", right?

http://www.facebook.com/photo.php?fbid=209275852434911

Reply