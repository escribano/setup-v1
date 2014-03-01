function copy.key {
  SERVER_NAME=$1
  scp -i ~/.ec2/rsa-ec2-sa.pem ~/.ssh/id_rsa.pub admin@$SERVER_NAME.mapa.io:
  #ssh -i ~/.ec2/rsa-ec2-sa.pem admin@basic.mapa.io
  #sudo -i
}

function create.me {
  useradd -m ademir -s /bin/bash
  echo "ademir ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-ademir
  chmod 0440 /etc/sudoers.d/init-ademir
}

function install.key {
  cp /home/admin/id_rsa.pub /home/ademir/
  chown ademir.ademir /home/ademir/id_rsa.pub
  su ademir
  cd /home/ademir
  mkdir .ssh
  cat id_rsa.pub >> ~/.ssh/authorized_keys
}