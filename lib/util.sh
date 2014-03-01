function show.function {
   declare -f "$1"
}

function update.me {
  SAVED_PWD=`pwd`
  cd $SETUP_ROOT_PATH
  git pull origin master
  cd $SAVED_PWD
}

function source.me {
  SAVED_PWD=`pwd`
  cd $SETUP_ROOT_PATH
  source ./install
  #git pull origin master
  cd $SAVED_PWD
}