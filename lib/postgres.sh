
function install.postgres {
  apt-get install postgresql-9.1-postgis libpq-dev -y
}

function stop.postgres {
  /etc/init.d/postgresql   stop
}

function move.cluster {
  # move cluster
  mkdir -p /mnt/ebs/db/{etc,lib,log}
  mv /etc/postgresql     /mnt/ebs/db/etc/
  mv /var/lib/postgresql /mnt/ebs/db/lib/
  mv /var/log/postgresql /mnt/ebs/db/log/
  mkdir /etc/postgresql /var/lib/postgresql /var/log/postgresql
  echo "/mnt/ebs/db/etc/postgresql /etc/postgresql none bind" | sudo tee -a /etc/fstab
  echo "/mnt/ebs/db/lib/postgresql /var/lib/postgresql none bind" | sudo tee -a /etc/fstab
  echo "/mnt/ebs/db/log/postgresql /var/log/postgresql none bind" | sudo tee -a /etc/fstab
  mount /etc/postgresql
  mount /var/lib/postgresql
  mount /var/log/postgresql
}

function confit.cluster {
  nano /etc/postgresql/9.1/main/pg_hba.conf
  # TYPE  DATABASE        USER            ADDRESS                 METHOD
  echo "
  local   all             all                                     trust
  local   all             all                                     ident map=admin
  local   all             all                                     ident
  local   all             all                                     peer
  local   all             all                                     md5
  " > include
	
  nano /etc/postgresql/9.1/main/pg_ident.conf
  # MAPNAME       SYSTEM-USERNAME         PG-USERNAME
  echo "
  admin           root                    postgres
  admin           ademir                  postgres
  admin           www-data                postgres
  " > include
}

function start.postgres {
  /etc/init.d/postgresql start
}


function more.postgres {
  psql -U postgres
  sudo -u postgres psql -p 5433
  /etc/init.d/postgresql   stop 9.3
  nano /etc/postgresql/9.3/main/pg_hba.conf
  nano /etc/postgresql/9.3/main/pg_ident.conf
  /etc/init.d/postgresql start 9.3
  /etc/init.d/postgresql start
}

