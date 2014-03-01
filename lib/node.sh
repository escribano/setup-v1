function install.node.latest {
  # apt-get update && apt-get upgrade -y
  # apt-get install build-essential python openssl libssl-dev curl
  # apt-get install python g++ make checkinstall

  cd ~
  mkdir src ; cd src
  wget -N http://nodejs.org/dist/node-latest.tar.gz
  tar xzvf node-latest.tar.gz && cd node-v*
  ./configure
  checkinstall -y --install=no --pkgversion 0.10.25  make -j$(($(nproc)+1)) install  # Replace with current version number.
  #dpkg -i node_*
  dpkg -i node_0.10.25-1_amd64.deb

  ###

}

function install.node.25 {
  # apt-get update && apt-get upgrade -y
  # apt-get install build-essential python openssl libssl-dev curl
  # apt-get install python g++ make checkinstall

  cd ~
  mkdir src ; cd src
  wget -N http://nodejs.org/dist/v0.10.25/node-v0.10.25.tar.gz
  tar xzvf node-v0.10.25.tar.gz && cd node-v*
  ./configure
  checkinstall -y --install=no --pkgversion 0.10.25  make -j$(($(nproc)+1)) install  # Replace with current version number.
  #dpkg -i node_*
  dpkg -i node_0.10.25-1_amd64.deb

  ###

}
