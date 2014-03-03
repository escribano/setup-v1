function show.function {
   declare -f "$1"
}

function pull.setup {
  SAVED_PWD=`pwd`
  cd $SETUP_ROOT_PATH
  git pull origin master
  cd $SAVED_PWD
}

function source.setup {
  SAVED_PWD=`pwd`
  cd $SETUP_ROOT_PATH
  source ./install
  #git pull origin master
  cd $SAVED_PWD
}

function push.setup {
  SAVED_PWD=`pwd`
  cd $SETUP_ROOT_PATH
  git add -A
  git commit -am 'fix'
  git push origin master
  cd $SAVED_PWD
}

function add.setup.to.bashrc () {
  echo "" >> ~/.bashrc
  echo "source $SETUP_ROOT_PATH/install" >> ~/.bashrc
  #echo "" >> .bashrc
}

function goto.setup () {
  cd ~/code/setup
}

function reset.known.hosts () {
  cat /dev/null > /Users/ademir/.ssh/known_hosts
}