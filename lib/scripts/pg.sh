#! /bin/bash
#
# Installs a node.js stack backed by PostgreSQL and fronted by nginx.
# <UDF name="user_username" Label="Main user name" />
# <UDF name="user_password" Label="Main user password" />
# <UDF name="user_ssh_key"  Label="Main user RSA SSH key" />
# <UDF name="postgres_root_password" Label="PostgreSQL root password" />
# <UDF name="nodejs_version" Label="Node.js version" default="0.6.14" />
#
# If not deploying to Linode, set these environment variables. All required:
#  - USER_USERNAME: the username you want for your main Linux user
#  - USER_PASSWORD: the password for this ^ user
#  - USER_SSH_KEY: the contents of an SSH public key. SSH will be locked out of password auth.
#  - POSTGRES_ROOT_PASSWORD: the password for the Postgres user in PostgreSQL
#  - NODEJS_VERSION: the version of node.js to install (e.g. "0.6.14")

# https://www.linode.com/stackscripts/view/?StackScriptID=4445


LOGFILE=~/stackscript.log

USER_HOMEDIR=/home/$USER_USERNAME

# set default shell to bash
sed -i '' -e "s|SHELL=/bin/sh|SHELL=/bin/bash|g" /etc/default/useradd;

# setup user
echo "Creating account username $USER_USERNAME" >> $LOGFILE
mkdir -p $USER_HOMEDIR;
useradd -p `openssl passwd -1 $USER_PASSWORD` -d $USER_HOMEDIR $USER_USERNAME
echo "User $USER_USERNAME created" >> $LOGFILE
usermod $USER_USERNAME -G admin
echo "User $USER_USERNAME added to group admin" >> $LOGFILE
echo "$USER_USERNAME	ALL=(ALL) ALL" >> /etc/sudoers
chmod 400 /etc/sudoers
echo "User $USER_USERNAME added to sudoers" >> $LOGFILE

# install SSH key
mkdir -p $USER_HOMEDIR/.ssh;
echo "$USER_SSH_KEY" > $USER_HOMEDIR/.ssh/authorized_keys
sed -i '' -e "s/\#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i '' -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
chown -R 700 $USER_HOMEDIR/.ssh;
chown 644 $USER_HOMEDIR/.ssh/authorized_keys;

# install git, build tools, OpenSSL
apt-get install -y git-core build-essential autoconf libssl-dev

pushd $USER_HOMEDIR;
echo "Pushed into $PWD" >> $LOGFILE;
mkdir -p packages;
pushd packages;
echo "Pushed into $PWD" >> $LOGFILE;

# install node.js
echo "Installing node.js at $PWD/node" >> $LOGFILE;
git clone https://github.com/joyent/node.git node;
pushd node;
echo "Pushed into $PWD" >> $LOGFILE;
git fetch origin;
git checkout v$NODEJS_VERSION;
echo "Checked out v$NODEJS_VERSION of node.js" >> $LOGFILE;
./configure >> $LOGFILE;
echo "Done configuring nodejs" >> $LOGFILE;
make >> $LOGFILE;
echo "Done making nodejs" >> $LOGFILE;
make install >> $LOGFILE;
echo "Made/installed nodejs"
popd;
chown -R $USER_USERNAME:$USER_USERNAME node;
popd;
popd;

# install npm
"echo Installing npm" >> $LOGFILE;
curl http://npmjs.org/install.sh | sh  >> $LOGFILE;

# install postgres
apt-get install -y postgresql-9.1 postgresql-contrib-9.1 libpq-dev;
echo "ALTER USER postgres with encrypted password '$POSTGRES_ROOT_PASSWORD';" | sudo -u postgres psql template1
npm install -g pg;

# fix postgres to allow local psql calls from non-postgres users
sed -i "" -e "s/\(local   all             postgres                                \)peer/\1md5/g" /etc/postgresql/9.1/main/pg_hba.conf

service postgresql restart;

# install nginx
apt-get install -y nginx;
service nginx restart;

# restart SSH
service ssh restart

#cleanup
chown -R $USER_USERNAME:$USER_USERNAME $USER_HOMEDIR;
echo "Done!"  >> $LOGFILE
