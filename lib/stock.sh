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
