function _config.args.new.basic.server () {
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

function new.basic.server () {
  # new.basic.server ip public
  # new.basic.server 42 true
  _config.args.new.basic.server $@
  echo "ip: 10.0.0.$IP"
  echo "public ip: $PUBLICIP"
  if [ $ERROR == true ]; then
    return 1
  fi
  BASIC_AMI=`ec2-describe-images --region sa-east-1 --filter tag:Name=basic.ami | awk '$1 == "IMAGE" {print $2}'`
  
  if [ $PUBLICIP == true ]; then
    ec2-run-instances $BASIC_AMI --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --associate-public-ip-address $PUBLICIP --disable-api-termination > $SETUP_ROOT_PATH/var/new.basic.server.txt
  else
    ec2-run-instances $BASIC_AMI --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --disable-api-termination > $SETUP_ROOT_PATH/var/new.basic.server.txt
  fi
  INSTANCE_ID=`cat $SETUP_ROOT_PATH/var/new.basic.server.txt | awk '$1 == "INSTANCE" {print $2}'`
  sleep 5

  ec2-create-tags --region sa-east-1 $INSTANCE_ID --tag "Name=ready"  > $SETUP_ROOT_PATH/var/tag.basic.instance.txt
  
  sleep 10
  ec2-describe-instances --region sa-east-1 $INSTANCE_ID > $SETUP_ROOT_PATH/var/basic.instance.txt
  cat $SETUP_ROOT_PATH/var/basic.instance.txt | awk '$1 == "INSTANCE" {print "instanceid: " $2 "\n" "dns: " $4 "\n" "ip: " $14}'
}

function associate.ready.ip () {
  EIPALLOC=`ec2-describe-addresses --region sa-east-1 54.207.66.208  | awk '$1 == "ADDRESS" {print $4}'`
  #ec2-associate-address --region sa-east-1 -i $INSTANCE_ID -a $EIPALLOC  --allow-reassociation
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=ready | awk '$1 == "INSTANCE" {print $2}'`
  ec2-associate-address --region sa-east-1 -i $INSTANCE_ID -a $EIPALLOC
}

function create.ready.ami () {
  # create.ready.ami
  #if [ -z "$1" ]; then
  #  echo "No argument supplied"
  #  return 1
  #fi
  #SERVER_NAME=$1
  SERVER_NAME="ready"
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
  #INSTANCE_ID=$1
  READY_AMI_NAME="ready-debian-jessie-testing-x86_64-ebs-$(date '+%Y-%m-%d')"
  #AMI_DESCRIPTION=$3
  #ec2-create-image $INSTANCE_ID --name $AMI_NAME --description $AMI_DESCRIPTION
  #ec2-create-image i-0cf2f919 --name basic-debian-jessie-testing-x86_64-ebs-2014-02-28
  ec2-create-image --region sa-east-1 $INSTANCE_ID --name $READY_AMI_NAME > $SETUP_ROOT_PATH/var/new.ready.ami.txt
  READY_AMI=`cat $SETUP_ROOT_PATH/var/new.ready.ami.txt | awk '$1 == "IMAGE" {print $2}'`
  ec2-create-tags --region sa-east-1 $READY_AMI --tag "Name=ready.ami"
  sleep 5
  ec2-describe-images --region sa-east-1 $READY_AMI
}

function end.setup.ready () {
  apt-get update && apt-get upgrade -y
  apt-get install build-essential curl git -y
  mkdir -p /opt/gis ; cd /opt/gis
  git clone https://github.com/escribano/setup.git
  cd setup
  source ./install
  add.setup.to.bashrc
  history -c
}

function show.create.ready.ami () {
  _show.header
  
  printf "$txtcyn"
  printf "new.basic.server ip false \n"
  printf "associate.ready.ip \n"
  printf "config dns ready \n"
  printf "ssh.admin ready \n"
  
  printf "$txtgrn"
  end.setup.ready

  printf "$txtcyn"
  printf "create.ready.ami \n"
  
  printf "$txtrst"
}

function show.create.new.mapa.ami () {
  _show.header
  
  printf "$txtcyn"
  printf "new.ready.server ip public \n"
  printf "or \n"
  printf "new.ready.server.block ip public \n"
  printf "and \n"
  printf "config dns mapa \n"
  printf "ssh.admin mapa \n"
  
  printf "$txtgrn"
  printf "update.setup \n"
  printf "source.setup \n"
  printf "update.jessie \n"
  printf "config.locale \n"

  printf "install.more.libs \n"
  printf "history -c \n"

  printf "$txtcyn"
  printf "create.mapa.ami i-79151f6c \n"
  
  printf "$txtrst"
}

