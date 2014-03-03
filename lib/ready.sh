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
  _config.args.new.basic.server $@
  echo "ip: 10.0.0.$IP"
  echo "public ip: $PUBLICIP"
  if [ $ERROR == true ]; then
    return 1
  fi

  ec2-run-instances ami-936bc88e --region sa-east-1 -z sa-east-1a -k rsa-ec2-sa -g sg-d5ffe3b7 -t m1.large -s subnet-97faf5fe --private-ip-address 10.0.0.$1 --associate-public-ip-address $PUBLICIP --disable-api-termination > $SETUP_ROOT_PATH/var/new.basic.server.txt

  INSTANCE=`cat $SETUP_ROOT_PATH/var/new.basic.server.txt | awk '$1 == "INSTANCE" {print $2}'`
  sleep 5
  ec2-create-tags --region sa-east-1 $INSTANCE --tag "Name=ready"  > $SETUP_ROOT_PATH/var/tag.basic.instance.txt
  sleep 10
  ec2-describe-instances --region sa-east-1 $INSTANCE > $SETUP_ROOT_PATH/var/basic.instance.txt
  cat $SETUP_ROOT_PATH/var/basic.instance.txt | awk '$1 == "INSTANCE" {print "instanceid: " $2 "\n" "dns: " $4 "\n" "ip: " $14}'

}

function show.create.ready.ami () {
  _show.header
  
  printf "$txtcyn"
  printf "new.basic.server ip public \n"
  printf "or \n"
  printf "new.basic.server.block ip public \n"
  printf "and \n"
  printf "config dns ready \n"
  printf "ssh.admin ready \n"
  
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
