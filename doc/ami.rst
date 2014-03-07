The basic approach to creating an EBS boot AMI is to create an EBS boot volume, copy your file system to it (rsync -PaSHAX), snapshot it, and register the EBS snapshot as a new AMI with the appropriate AKI and ARI. You can start with a downloaded image from Ubuntu, or the file system of a running EC2 instance.

Creating a New Image for EC2 by Rebundling a Running Instance
=============================================================

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
