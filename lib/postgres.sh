
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

function config.cluster {
  cp /etc/postgresql/9.3/main/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf.backup
  echo "
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
local   all             all                                     ident map=admin
local   all             all                                     ident
local   all             all                                     peer
local   all             all                                     md5
  " > /etc/postgresql/9.3/main/include_auth_hba.conf
  
  sed -n 'H;${x;s/# DO NOT DISABLE!.*\n/include "include_auth_hba.conf"\n\n\n&/;p;}' /etc/postgresql/9.3/main/pg_hba.conf
  
  #include 'filename'
  #include_dir 'directory'
  #nano /etc/postgresql/9.3/main/pg_hba.conf
  #grep "^[a-z]" /etc/postgresql/9.3/main/pg_hba.conf
  #sed '/^JAVA_HOME/a this is the new line' filename > newfilename
  #sed -n 'H;${x;s/nameserver .*\n/nameserver 127.0.0.1\n&/;p;}' resolv.conf
  #sed -n 'H;${x;s/^\n//;s/nameserver .*\n/nameserver 127.0.0.1\n&/;p;}' resolv.conf
  #sed -n 'H;${x;s/^\n//;s/nameserver .*$/nameserver 127.0.0.1\n&/;p;}' resolv.conf
  # TYPE  DATABASE        USER            ADDRESS                 METHOD

	# DO NOT DISABLE!
  #sed -n 'H;${x;s/# DO NOT DISABLE!.*\n/include "include_auth_hba.conf"\n\n\n&/;p;}' /etc/postgresql/9.3/main/pg_hba.conf
  #sed '/^# DO NOT DISABLE!/include thefile' /etc/postgresql/9.3/main/pg_hba.conf
  #sed -n 'H;${x;s/DISABLE .*\n/include thefile\n&/;p;}' /etc/postgresql/9.3/main/pg_hba.conf
  #sed -n 'H;${x;s/^\n//;s/DISABLE .*$/include thefile\n&/;p;}' /etc/postgresql/9.3/main/pg_hba.conf
  #nano /etc/postgresql/9.3/main/pg_ident.conf
  # MAPNAME       SYSTEM-USERNAME         PG-USERNAME
  #echo "
  #admin           root                    postgres
  #admin           ademir                  postgres
  #admin           www-data                postgres
  #" > include
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

function find.postgres () {
  ps -ef | grep postgres
  psql -d postgres -c "SHOW hba_file;"
  cat /usr/local/var/postgres/pg_hba.conf
}