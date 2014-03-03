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
