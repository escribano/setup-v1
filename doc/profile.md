
cat .ssh/authorized_keys
ls -alh /etc/profile.d


cat /etc/bash.bashrc
cat /etc/profile
cat .bashrc
cat .profile

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f /etc/bashrc ] ; then
  . /etc/bashrc
fi

if [ "`id -u`" -eq 0 ]; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else
  PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
fi
export PATH

debian_chroot=$(cat /etc/debian_chroot)
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
/etc/bash_completion

if [ "$PS1" ]; then
  if [ "$BASH" ]; then
  
vi 
vi /etc/habisp
chmod u+x /etc/habisp


vi /etc/profile.d/habisp

echo "export CVS_RSH=ssh" >> /etc/profile.d/habisp.sh
chmod +x /etc/profile.d/habisp.sh




vhostname=$VHOSTNAME
PS1='${debian_chroot:+($debian_chroot)}\u@\h:(le ${vhostname}):\w \$ '

chmod +x /etc/profile.d/habisp.sh


PS1='${debian_chroot:+($debian_chroot)}\u@\h:(`echo $VHOSTNAME`):\w \$ '
VHOSTNAME='dc1-spa'