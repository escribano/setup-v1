#!/bin/bash

##
# Taken from http://www.linode.com/stackscripts/view/?StackScriptID=124.

# https://www.linode.com/stackscripts/view/?StackScriptID=1387

function system_start_etc_dir_versioning {
  aptitude -y install git-core
 
  pushd /etc
  
  git init
  git add .
  git commit -m "Started versioning of /etc directory"

  popd
}

##
# Taken from http://www.linode.com/stackscripts/view/?StackScriptID=123.

function system_add_ssh_key {
  local username=${1}
  local homedir=${2}
  local key=${3}

  aptitude -y install wget

  sudo -u ${username} mkdir -p ${homedir}/.ssh
  sudo -u ${username} wget -O ${homedir}/.ssh/authorized_keys ${key}
  chmod 0600 "${homedir}/.ssh/authorized_keys"
}

function has_key? {
  local database=${1}
  local key=${2}

  getent ${database} ${key} >/dev/null 2>&1
  [ $? == 0 ] && true || false
}

function system_adduser {
  local login=${1}
  local homedir=${2}

  if ! has_key? passwd ${login}; then
    adduser --debug --disabled-password --home ${homedir} --gecos "" ${login}
  fi
}

function system_groupadd {
  local group=${1}
  
  if ! has_key? group ${group}; then
    groupadd ${group}
  fi
}

function system_suppl_group {
  local suppl_group=${1}
  local group=${2}

  usermod -a -G ${suppl_group} ${group}
}