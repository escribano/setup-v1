#!/bin/bash

# https://www.linode.com/stackscripts/view/?StackScriptID=1380

PACKAGES=(
  ack-grep
  gdb
  htop
  mtr
  netcat
  screen
  smem
  socat
  telnet
  tree 
  man-db
  curl
  wget
  zsh
  strace
  ltrace
  lsof
  sysstat
  whois
  manpages
  rsync
  dnsutils
  sudo
)

function enable {
  local file=${1}

  sed -i 's/\(ENABLED=\).*/\1"true"/' ${file}
}

aptitude -y install ${PACKAGES[@]}

enable /etc/default/sysstat