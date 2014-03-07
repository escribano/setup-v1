show hostname
hostname

show ip
/sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'

show all ips
/sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }'


external ip
wget -O - -q icanhazip.com

VHOSTNAME='dc1-spa'
echo $VHOSTNAME

prompt fix server name
echo $PS1
${debian_chroot:+($debian_chroot)}\u@\h:\w\$


PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w::-\H:\j:\s::-\$"
PS1='${debian_chroot:+($debian_chroot)}\u@\h:(dc1-spa):\w \$ '
PS1='${debian_chroot:+($debian_chroot)}\u@\h:[`$VHOSTNAME`]:\w \$ '
PS1='${debian_chroot:+($debian_chroot)}\u@\h:(`echo $VHOSTNAME`):\w \$ '


echo $PS2


Task: Linux Change root's User Password

To change root's password, you must first login as root user or use sudo / su command to obtain root's credentials. To become the root user, enter:
$ su -l

OR
$ sudo -s

Next, to change root's password, enter:
# passwd

