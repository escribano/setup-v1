function _config.args.new.ready.server () {
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

function new.ready.server () {
  # new.basic.server ip public
  _config.args.new.ready.server $@
  echo "ip: 10.0.0.$IP"
  echo "public ip: $PUBLICIP"
  if [ $ERROR == true ]; then
    return 1
  fi
  
  #MAPA_AMI=`ec2-describe-images --region sa-east-1 --filter tag:Name=mapa.ami.v2 | awk '$1 == "IMAGE" {print $2}'`
  READY_AMI=`ec2-describe-images --region sa-east-1 --filter tag:Name=ready.ami | awk '$1 == "IMAGE" {print $2}'`
  

  #INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
#echo $INSTANCE_ID

  if [ $PUBLICIP == true ]; then
    ec2-run-instances $READY_AMI --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --associate-public-ip-address $PUBLICIP --disable-api-termination > $SETUP_ROOT_PATH/var/new.ready.server.txt
  else
    ec2-run-instances $READY_AMI --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --disable-api-termination > $SETUP_ROOT_PATH/var/new.ready.server.txt
  fi

  INSTANCE_ID=`cat $SETUP_ROOT_PATH/var/new.ready.server.txt | awk '$1 == "INSTANCE" {print $2}'`
  sleep 5

  ec2-create-tags --region sa-east-1 $INSTANCE_ID --tag "Name=mapa"  > $SETUP_ROOT_PATH/var/tag.mapa.instance.txt

  sleep 10
  ec2-describe-instances --region sa-east-1 $INSTANCE_ID > $SETUP_ROOT_PATH/var/mapa.instance.txt
  cat $SETUP_ROOT_PATH/var/mapa.instance.txt | awk '$1 == "INSTANCE" {print "instanceid: " $2 "\n" "dns: " $4 "\n" "ip: " $14}'
}

function associate.mapa.ip () {
  EIPALLOC=`ec2-describe-addresses --region sa-east-1 54.207.32.0  | awk '$1 == "ADDRESS" {print $4}'`
  #ec2-associate-address --region sa-east-1 -i $INSTANCE_ID -a $EIPALLOC  --allow-reassociation
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=mapa | awk '$1 == "INSTANCE" {print $2}'`
  ec2-associate-address --region sa-east-1 -i $INSTANCE_ID -a $EIPALLOC
}

function create.mapa.ami () {
  # create.ready.ami
  #if [ -z "$1" ]; then
  #  echo "No argument supplied"
  #  return 1
  #fi
  #SERVER_NAME=$1
  SERVER_NAME="mapa"
  INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
  #INSTANCE_ID=$1
  MAPA_AMI_NAME="mapa-debian-jessie-testing-x86_64-ebs-$(date '+%Y-%m-%d')"
  #AMI_DESCRIPTION=$3
  #ec2-create-image $INSTANCE_ID --name $AMI_NAME --description $AMI_DESCRIPTION
  #ec2-create-image i-0cf2f919 --name basic-debian-jessie-testing-x86_64-ebs-2014-02-28
  ec2-create-image --region sa-east-1 $INSTANCE_ID --name $MAPA_AMI_NAME > $SETUP_ROOT_PATH/var/new.mapa.ami.txt
  MAPA_AMI=`cat $SETUP_ROOT_PATH/var/new.mapa.ami.txt | awk '$1 == "IMAGE" {print $2}'`
  ec2-create-tags --region sa-east-1 $MAPA_AMI --tag "Name=mapa.ami"
  sleep 5
  ec2-describe-images --region sa-east-1 $MAPA_AMI
}

function end.setup.mapa () {
  update.setup
  source.setup
  update.jessie
  config.locale

  install.more.libs
  history -c
}

function show.create.mapa.ami () {
  _show.header
  
  printf "$txtcyn"
  printf "new.ready.server ip false \n"
  printf "associate.mapa.ip \n"
  printf "config dns mapa \n"
  printf "ssh.admin mapa \n"
  
  printf "$txtgrn"
  end.setup.mapa

  printf "$txtcyn"
  printf "create.mapa.ami \n"
  
  printf "$txtrst"
}

