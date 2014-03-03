#!/bin/bash

###########################################################
# utilitary functions
###########################################################

function show.debian.ami () {
  echo "
  ami-9717b78a
  Debian Wheezy 7.4 SA-East-1 ami-9717b78a Para-virtualisation (PVM) EBS x86_64
  debian-wheezy-amd64-pvm-2014-02-08-ebs - ami-9717b78a
  Debian wheezy amd64
  Root device type: ebs Virtualization type: paravirtual 64-bit

  ec2-describe-group --region sa-east-1 sg-d5ffe3b7
  "
  ec2-describe-images  --region sa-east-1 ami-9717b78a
}

function _config.args.new.server () {
  #if [ $# -eq 0 ]
  #  then
  #    echo "No arguments supplied"
  #fi
  ERROR=false
  PUBLICIP=false
  IP=false
  if [ -z "$1" ]
    then
      echo "No argument supplied"
      ERROR=true
      return 1
  fi
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
     echo "error: Not a number" >&2; ERROR=true; return 1
  fi
  IP=$1
  #PUBLICIP=false
  if [ $2 == true ]; then
    PUBLICIP=true
  fi
}

function new.server () {
  _config.args.new.server $@
  echo "ip: 10.0.0.$IP"
  echo "public ip: $PUBLICIP"
  if [ $ERROR == true ]; then
    return 1
  fi
  ec2-run-instances ami-9717b78a --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --associate-public-ip-address $PUBLICIP --disable-api-termination > $SETUP_ROOT_PATH/var/create.server.txt
  #echo "run:"
  #echo " ec2-describe-instances --region sa-east-1 instanceid"
  #echo " dns"
  #echo " ssh -i ~/.ec2/rsa-ec2-sa.pem admin@servername.mapa.io"
  #echo " sudo -i"
  describe.instance
}

function describe.instance () {
  INSTANCE=`cat $SETUP_ROOT_PATH/var/create.server.txt | awk '$1 == "INSTANCE" {print $2}'`
  ec2-describe-instances --region sa-east-1 $INSTANCE > $SETUP_ROOT_PATH/var/instance.txt
  cat var/instance.txt | awk '$1 == "INSTANCE" {print "instanceid: " $2 "\n" "dns: " $4 "\n" "ip: " $14}'
  #ec2-create-tags $INSTANCE --tag "name=basic.ami"
}

function tag.instance.basic.ami () {
  describe.instance
  ec2-create-tags --region sa-east-1 $INSTANCE --tag "Name=basic.ami"  > $SETUP_ROOT_PATH/var/tag-instance-basic-ami.txt
}

function upgrade.to.jessie () {
  cp /etc/apt/sources.list{,.bak}
  sed -i -e 's/\(stable\|wheezy\)/jessie/ig' /etc/apt/sources.list
  apt-get update
  apt-get --download-only dist-upgrade -y
  apt-get dist-upgrade -y
  history -c
  #clean history, cache, etc
  #ami name
}

function ssh.admin () {
  SERVER_NAME=$1
  ssh -i ~/.ec2/rsa-ec2-sa.pem admin@$SERVER_NAME.mapa.io
}

function create.basic.ami () {
  # create.basic.ami i-0cf2f919
  if [ -z "$1" ]
    then
      echo "No argument supplied"
      return 1
  fi
  INSTANCE_ID=$1
  AMI_NAME="basic-debian-jessie-testing-x86_64-ebs-$(date '+%Y-%m-%d')"
  #AMI_DESCRIPTION=$3
  #ec2-create-image $INSTANCE_ID --name $AMI_NAME --description $AMI_DESCRIPTION
  #ec2-create-image i-0cf2f919 --name basic-debian-jessie-testing-x86_64-ebs-2014-02-28
  ec2-create-image --region sa-east-1 $INSTANCE_ID --name $AMI_NAME > $SETUP_ROOT_PATH/var/basic-ami.txt
}

function describe.basic.ami () {
  BASIC_AMI=`cat $SETUP_ROOT_PATH/var/basic-ami.txt | awk '$1 == "IMAGE" {print $2}'`
  ec2-describe-images --region sa-east-1 $BASIC_AMI # > $SETUP_ROOT_PATH/var/instance.txt
  #cat var/instance.txt | awk '$1 == "INSTANCE" {print "instanceid: " $2 "\n" "dns: " $4 "\n" "ip: " $14}'
  #ec2-create-tags $INSTANCE --tag "name=basic.ami"
}

function tag.basic.ami () {
  describe.basic.ami
  ec2-create-tags --region sa-east-1 $BASIC_AMI --tag "Name=basic.ami"
}

function create.mapa.ami () {
  # create.mapa.ami i-79151f6c
  if [ -z "$1" ]
    then
      echo "No argument supplied"
      return 1
  fi
  INSTANCE_ID=$1
  AMI_NAME="mapa-v2-debian-jessie-testing-x86_64-ebs-$(date '+%Y-%m-%d')"
  #AMI_DESCRIPTION=$3
  #ec2-create-image $INSTANCE_ID --name $AMI_NAME --description $AMI_DESCRIPTION
  #ec2-create-image i-0cf2f919 --name basic-debian-jessie-testing-x86_64-ebs-2014-02-28
  ec2-create-image --region sa-east-1 $INSTANCE_ID --name $AMI_NAME > $SETUP_ROOT_PATH/var/mapa.ami.txt
  MAPA_AMI=`cat $SETUP_ROOT_PATH/var/mapa.ami.txt | awk '$1 == "IMAGE" {print $2}'`
  ec2-create-tags --region sa-east-1 $MAPA_AMI --tag "Name=mapa.ami.v2"
  ec2-describe-images --region sa-east-1 $MAPA_AMI
}

function describe.mapa.ami () {
  MAPA_AMI=`cat $SETUP_ROOT_PATH/var/mapa.ami.txt | awk '$1 == "IMAGE" {print $2}'`
  ec2-describe-images --region sa-east-1 $MAPA_AMI # > $SETUP_ROOT_PATH/var/instance.txt
  #cat var/instance.txt | awk '$1 == "INSTANCE" {print "instanceid: " $2 "\n" "dns: " $4 "\n" "ip: " $14}'
  #ec2-create-tags $INSTANCE --tag "name=basic.ami"
}

function tag.mapa.ami () {
  describe.mapa.ami
  ec2-create-tags --region sa-east-1 $MAPA_AMI --tag "Name=mapa.ami.v1"
}

function install.mapa.instance () {
  create.me
  install.key
  install.node.25
  mount.ebs.data
  mount.ebs.db
  mount.ebs.mapa
  install.postgres
  stop.postgres
  move.cluster
  start.postgres
}

function more.functions () {
  ec2-allocate-address --region sa-east-1
  ec2-assign-private-ip-addresses --region sa-east-1
  ec2-associate-address --region sa-east-1
  ec2-describe-addresses --region sa-east-1
  ec2-describe-availability-zones --region sa-east-1
  ec2-describe-images --region sa-east-1
  ec2-describe-instances --region sa-east-1 --filter tag:Name=basic.ami | awk '$1 == "INSTANCE" {print $2}'
  ec2-describe-regions --region sa-east-1
  ec2-describe-snapshots --region sa-east-1
  ec2-describe-volumes --region sa-east-1
  ec2-detach-volume --region sa-east-1
  ec2-disassociate-address --region sa-east-1
  ec2-reboot-instances --region sa-east-1
  ec2-start-instances --region sa-east-1
  ec2-stop-instances --region sa-east-1
  ec2-run-instances --region sa-east-1
  ec2-unassign-private-ip-addresses --region sa-east-1
  ec2-terminate-instances --region sa-east-1
  ec2-describe-tags --region sa-east-1
}

function _show.header () {
  printf "$txtcyn"
  printf "mac "
  printf "$txtgrn"
  printf "jessie \n"
  printf "$txtwht"
  printf "—————―—————― \n"
  printf "$txtrst"
}

function show.create.basic.ami () {
  _show.header

  printf "$txtcyn"
  printf "new.server ip public \n"
  printf "describe.instance \n"
  printf "tag.instance.basic.ami \n"
  printf "config dns basic.ami \n"
  printf "ssh.admin basic.ami \n"
  
  printf "$txtgrn"
  printf "sudo -i \n"
  printf "upgrade.to.jessie \n"
  printf "history -c \n"
  
  printf "$txtcyn"
  printf "create.basic.ami \n"
  printf "describe.basic.ami \n"
  printf "tag.basic.ami \n"
  
  printf "$txtrst"
}


function show.create.mapa.ami () {
  _show.header
  
  printf "$txtcyn"
  printf "new.basic.server ip public \n"
  printf "or \n"
  printf "new.basic.server.block ip public \n"
  printf "and \n"
  printf "describe.instance.mapa.ami \n"
  printf "tag.instance.mapa.ami \n"
  printf "config dns mapa.ami \n"
  printf "ssh.admin mapa.ami \n"
  
  printf "$txtgrn"
  printf "install.basic.libs \n"

  printf "$txtcyn"
  printf "create ready ami \n"

  printf "$txtgrn"
  printf "git clone https://github.com/escribano/setup.git \n"
  printf "install.more.libs \n"
  printf "history -c \n"

  printf "$txtcyn"
  printf "create.mapa.ami i-0cf2f919 \n"
  
  printf "$txtrst"
}

function show.install.mapa.server () {
  _show.header
  
  printf "$txtcyn"
  
  printf "new.mapa.server ip public \n"
  printf "or \n"
  printf "new.mapa.server.block ip public \n"
  printf "and \n"
  #printf "describe.instance INSTANCE_ID \n"
  #printf "tag.instance INSTANCE_ID INSTANCE_NAME \n"
  printf "create ip \n"
  printf "config dns SERVER_NAME \n"
  
  printf "transfer.ebs.data <servername> \n"
  #printf "create.ebs.data INSTANCE_ID \n"
  printf "create.ebs.db <servername> \n"
  #printf "create.ebs.mapa INSTANCE_ID \n"
  printf "copy.key <servername> \n"
  printf "ssh.admin <servername> \n"

  printf "$txtgrn"
  printf "update.setup \n"
  printf "source.setup \n"
  printf "update.jessie \n"
  #printf "config.locale \n"
  printf "create.me \n"
  printf "install.key \n"
  printf "install.node.25 \n"
  printf "mount.ebs.data \n"
  printf "mount.ebs.db \n"
  #printf "mount.ebs.mapa \n"
  #printf "setup.postgres \n"
  printf "install.db \n"
  
  printf "$txtrst"
}

function ec2.help () {
  echo "
    show.debian.ami
    new.server
    upgrade.to.jessie
    show.create.basic.ami
    show.create.mapa.ami
    show.install.mapa.server
  "
}
