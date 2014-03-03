function mount.ephemeral () {
  #DEVICE_LETTER=$1
  #MOUNT_NAME=$2
  #mkfs.xfs /dev/xvd$DEVICE_LETTER
  #mkdir -p /mnt/ebs/$MOUNT_NAME
  #echo "/dev/xvd$DEVICE_LETTER /mnt/ebs/$MOUNT_NAME xfs noatime 0 0" | sudo tee -a /etc/fstab
  echo "/dev/xvdc /mnt/eph0 ext3 defaults 0 0" | sudo tee -a /etc/fstab
  mkdir /mnt/eph0
  mount /mnt/eph0
  #mount /mnt/ebs/$MOUNT_NAME
}