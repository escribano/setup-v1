function install.setup () {
  SAVED_PWD=`pwd`
  if [ "$UNAME" == "Linux" ]; then
    mkdir -p opt/gis ; cd opt/gis
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
    mkdir -p opt/gis ; cd opt/gis
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
  mount.ebs.data
  mount.ebs.db
  install.db
}

