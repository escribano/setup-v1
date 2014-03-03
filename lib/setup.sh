function _config.args.new.mapa.server () {
  #if [ $# -eq 0 ]
  #  then
  #    echo "No arguments supplied"
  #fi
  ERROR=false
  PUBLICIP=false
  EPHEMERAL=false
  IP=false
  if [ -z "$1" ]
    then
      echo "No argument supplied"
      ERROR=true
      return 1
  fi
  SERVER_NAME=$1
  re='^[0-9]+$'
  if ! [[ $2 =~ $re ]] ; then
     echo "error: Not a number" >&2; ERROR=true; return 1
  fi
  IP=$2
  #PUBLICIP=false
  if [ $3 == true ]; then
    PUBLICIP=true
  fi
  if [ $4 == true ]; then
    EPHEMERAL=true
  fi
}

function new.mapa.server () {
  # new.mapa.server name ip public ephemeral
  _config.args.new.mapa.server $@
  echo "name is $SERVER_NAME"
  echo "ip is 10.0.0.$IP"
  echo "public ip is $PUBLICIP"
  echo "ephemeral is $EPHEMERAL"
  if [ $ERROR == true ]; then
    return 1
  fi
  
  #MAPA_AMI=`ec2-describe-images --region sa-east-1 --filter tag:Name=mapa.ami.v2 | awk '$1 == "IMAGE" {print $2}'`
  MAPA_AMI=`ec2-describe-images --region sa-east-1 --filter tag:Name=mapa.ami | awk '$1 == "IMAGE" {print $2}'`
  

  #INSTANCE_ID=`ec2-describe-instances --region sa-east-1 --filter tag:Name=$SERVER_NAME | awk '$1 == "INSTANCE" {print $2}'`
#echo $INSTANCE_ID
  #--block-device-mapping '/dev/sda2=ephemeral0'
  #--block-device-mapping '/dev/sda3=ephemeral1'
  #/dev/sdb=ephemeral0, /dev/sdc=ephemeral1, /dev/sdd=ephemeral2, /dev/sde=ephemeral3
  
  EPHEM_ARG=""
  if $EPHEMERAL; then
    EPHEM_ARG='-b "/dev/sdc=ephemeral0" -b "/dev/sdd=ephemeral1"'
    #EPHEM_ARG="--block-device-mapping '/dev/sdb=ephemeral0' --block-device-mapping '/dev/sdc=ephemeral1'"
  fi
  
  CONST_ARG="--region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe"
  
  ASSOC_IP=""
  if "$PUBLICIP"; then
    ASSOC_IP="--associate-public-ip-address $PUBLICIP"
    #echo "merda"
  fi
  
  RUN_INST="ec2-run-instances $MAPA_AMI $CONST_ARG --private-ip-address 10.0.0.$IP $ASSOC_IP $EPHEM_ARG --disable-api-termination"
  echo $RUN_INST
  $RUN_INST > $SETUP_ROOT_PATH/var/new.mapa.server.txt
  #return
  #if [ $PUBLICIP == true ]; then
  #  ec2-run-instances $READY_AMI --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --associate-public-ip-address $PUBLICIP --disable-api-termination > $SETUP_ROOT_PATH/var/new.mapa.server.txt
  #else
  #  ec2-run-instances $READY_AMI --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --disable-api-termination > $SETUP_ROOT_PATH/var/new.mapa.server.txt
  #fi

  INSTANCE_ID=`cat $SETUP_ROOT_PATH/var/new.mapa.server.txt | awk '$1 == "INSTANCE" {print $2}'`
  sleep 5

  ec2-create-tags --region sa-east-1 $INSTANCE_ID --tag "Name=$SERVER_NAME"  > $SETUP_ROOT_PATH/var/tag.mapa.instance.txt

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

function install.setup () {
  SAVED_PWD=`pwd`
  if [ "$UNAME" == "Linux" ]; then
    mkdir -p /opt/gis ; cd /opt/gis
    git clone https://github.com/escribano/setup.git
  elif [ "$UNAME"  == "Darwin" ]; then
    mkdir -p ~/code/gis ; cd ~/code/gis
    git clone git@github.com:escribano/setup.git
  fi
  cd setup
  source ./install
  add.setup.to.bashrc
  cd $SAVED_PWD
}

function install.db () {
  SAVED_PWD=`pwd`
  if [ "$UNAME" == "Linux" ]; then
    mkdir -p /opt/gis ; cd /opt/gis
    git clone https://github.com/escribano/db.git
  elif [ "$UNAME"  == "Darwin" ]; then
    mkdir -p ~/code/gis ; cd ~/code/gis
    git clone git@github.com:escribano/db.git
  fi
  cd db
  source ./install
  add.db.to.bashrc
  cd $SAVED_PWD
}

function install.http () {
  SAVED_PWD=`pwd`
  if [ "$UNAME" == "Linux" ]; then
    mkdir -p /opt/gis ; cd /opt/gis
    git clone https://github.com/escribano/http.git
  elif [ "$UNAME"  == "Darwin" ]; then
    mkdir -p ~/code/gis ; cd ~/code/gis
    git clone git@github.com:escribano/http.git
  fi
  cd http
  source ./install
  add.http.to.bashrc
  cd $SAVED_PWD
}

function begin.setup.server () {
  # begin.setup.server ready
  if [ -z "$1" ]; then
    echo "No argument supplied"
    return 1
  fi
  SERVERNAME=$1
  transfer.ebs.data $SERVERNAME
  create.ebs.db $SERVERNAME
  copy.key $SERVERNAME
  ssh.admin $SERVERNAME
}

function end.setup.server () {
  update.setup
  source.setup
  update.jessie
  create.me
  install.key
  install.node.25
  remount.ebs.data
  mount.ebs.db
  install.db
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
  printf "associate.mapa.ip \n"
  printf "config dns mapa \n"
  
  printf "begin.setup.server mapa \n"

  printf "$txtgrn"
  printf "end.setup.server \n"
  
  printf "$txtrst"
}
