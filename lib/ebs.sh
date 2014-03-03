function create.ebs {
  # mac
  ec2-create-volume --region sa-east-1 -z sa-east-1a -s 30
  ec2-describe-volumes --region sa-east-1 vol-c893899a
  ec2-attach-volume --region sa-east-1 -d /dev/xvdg -i i-f6bcb1e3 vol-c893899a
}

function _attach.volume () {
  DEVICE_LETTER=$1
  INSTANCE_ID=$2
  VOLUME_ID=$3
  #ec2-describe-volumes --region sa-east-1 $VOLUME_ID
  ec2-attach-volume --region sa-east-1 -d /dev/xvd$DEVICE_LETTER -i $INSTANCE_ID $VOLUME_ID
}

function create.ebs.data {
  SERVER_NAME=$1
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
  #echo $INSTANCE_ID
  ec2-create-volume --region sa-east-1 -z sa-east-1a -s 20 > $SETUP_ROOT_PATH/var/create.ebs.data.txt
  VOLUME_ID=`cat $SETUP_ROOT_PATH/var/create.ebs.data.txt | awk '$1 == "VOLUME" {print $2}'`
  sleep 15
  _attach.volume f $INSTANCE_ID $VOLUME_ID
  sleep 15
  ec2-create-tags --region sa-east-1 $VOLUME_ID --tag "Name=mapa.data"
  ec2-describe-volumes --region sa-east-1 $VOLUME_ID
}

function transfer.ebs.data {
  SERVER_NAME=$1
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
  VOLUME_ID=`ec2-describe-volumes --region sa-east-1 --filter tag:Name=mapa.data | awk '$1 == "VOLUME" {print $2}'`
  #echo $INSTANCE_ID
  #ec2-create-volume --region sa-east-1 -z sa-east-1a -s 20 > $SETUP_ROOT_PATH/var/create.ebs.data.txt
  #VOLUME_ID=`cat $SETUP_ROOT_PATH/var/create.ebs.data.txt | awk '$1 == "VOLUME" {print $2}'`
  #sleep 15
  _attach.volume f $INSTANCE_ID $VOLUME_ID
  #echo $INSTANCE_ID
  #echo $VOLUME_ID
  sleep 5
  #ec2-create-tags --region sa-east-1 $VOLUME_ID --tag "Name=mapa.data"
  ec2-describe-volumes --region sa-east-1 $VOLUME_ID
}


function create.ebs.db {
  SERVER_NAME=$1
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
  #echo $INSTANCE_ID
  ec2-create-volume --region sa-east-1 -z sa-east-1a -s 10 > $SETUP_ROOT_PATH/var/create.ebs.db.txt
  VOLUME_ID=`cat $SETUP_ROOT_PATH/var/create.ebs.db.txt | awk '$1 == "VOLUME" {print $2}'`
  sleep 15
  _attach.volume p $INSTANCE_ID $VOLUME_ID
  sleep 15
  ec2-create-tags --region sa-east-1 $VOLUME_ID --tag "Name=mapa.db"
  ec2-describe-volumes --region sa-east-1 $VOLUME_ID
}

function create.ebs.mapa {
  SERVER_NAME=$1
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
  #echo $INSTANCE_ID
  ec2-create-volume --region sa-east-1 -z sa-east-1a -s 10 > $SETUP_ROOT_PATH/var/create.ebs.mapa.txt
  VOLUME_ID=`cat $SETUP_ROOT_PATH/var/create.ebs.mapa.txt | awk '$1 == "VOLUME" {print $2}'`
  sleep 15
  _attach.volume m $INSTANCE_ID $VOLUME_ID
  sleep 15
  ec2-create-tags --region sa-east-1 $VOLUME_ID --tag "Name=mapa.server"
  ec2-describe-volumes --region sa-east-1 $VOLUME_ID
}

function fdisk.debian {
  fdisk -l
}

function mount.ebs {
  mkfs.xfs /dev/xvdg
  mkdir -p /mnt/ebs
  echo "/dev/xvdg /mnt/ebs xfs noatime 0 0" | sudo tee -a /etc/fstab
  mount /mnt/ebs
}

function _mount.ebs () {
  DEVICE_LETTER=$1
  MOUNT_NAME=$2
  mkfs.xfs /dev/xvd$DEVICE_LETTER
  mkdir -p /mnt/ebs/$MOUNT_NAME
  echo "/dev/xvd$DEVICE_LETTER /mnt/ebs/$MOUNT_NAME xfs noatime 0 0" | sudo tee -a /etc/fstab
  mount /mnt/ebs/$MOUNT_NAME
}

function _remount.ebs () {
  DEVICE_LETTER=$1
  MOUNT_NAME=$2
  #mkfs.xfs /dev/xvd$DEVICE_LETTER
  mkdir -p /mnt/ebs/$MOUNT_NAME
  echo "/dev/xvd$DEVICE_LETTER /mnt/ebs/$MOUNT_NAME xfs noatime 0 0" | sudo tee -a /etc/fstab
  mount /mnt/ebs/$MOUNT_NAME
}

function mount.ebs.data {
  _remount.ebs f data
}

function remount.ebs.data {
  _mount.ebs f data
}

function mount.ebs.db {
  _mount.ebs p db
}

function mount.ebs.mapa {
  _mount.ebs m mapa
}