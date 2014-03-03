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
