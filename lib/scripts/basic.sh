#!/bin/bash
#
# Basic Debian 6 StackScript
# By Zach Seifts <zach.seifts@gmail.com>
# https://www.linode.com/stackscripts/view/?StackScriptID=5830
#
# <udf name="domain" Label="Domain name" />
# <udf name="db_password" Label="MySQL root Password" />
# <udf name="user_name" label="Unprivileged User Account" />
# <udf name="user_password" label="Unprivileged User Password" />
# <udf name="user_sshkey" label="Public Key for Unprivileged User" default="" />
#
# <udf name="sshd_port" label="SSH Port" default="22" />
# <udf name="sshd_protocol" label="SSH Protocol" oneOf="1,2,1 and 2" default="2" />
# <udf name="sshd_permitroot" label="SSH Permit Root Login" oneof="No,Yes" default="No" />
# <udf name="sshd_passwordauth" label="SSH Password Authentication" oneOf="No,Yes" default="No" />
# <udf name="sshd_group" label="SSH Allowed Groups" default="sshusers" example="List of groups seperated by spaces" />
#
# <udf name="sudo_usergroup" label="Usergroup to use for Admin Accounts" default="wheel" />
# <udf name="sudo_passwordless" label="Passwordless Sudo" oneof="Require Password,Do Not Require Password", default="Require Password" />

source <ssinclude StackScriptID="1">

exec &> /root/stackscript.log

function set_hostname {
  # set the hostname and the fqdn
  echo $DOMAIN > /etc/hostname
  hostname -F /etc/hostname

  ipAddr=$(ip -f inet -r addr | egrep -o "(([0-9]{3}+).*)/24" | sed 's/\/24//')
  echo $ipAddr $DOMAIN >> /etc/hosts
}

function set_security {
  aptitude install fail2ban
}

function config_iptables {
  # based on: https://help.ubuntu.com/community/IptablesHowTo
  # and http://www.thegeekstuff.com/2011/06/iptables-rules-examples/

  # allow established sessions to recieve traffic
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  # allow loopback/127.0.0.1 traffic
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT

  # allow ssh traffic
  iptables -A INPUT -p tcp --dport ssh -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --sport ssh -m state --state ESTABLISHED -j ACCEPT

  # allow http traffic
  iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

  # allow https traffic
  iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

  # allow pings from the outside world
  iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
  iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

  # setting uplogging
  iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

  # drop the rest
  iptables -A INPUT -j DROP

  # saving the rules
  iptables-save > /etc/iptables.rules
  echo "  pre-up iptables-restore < /etc/iptables.rules" >> /etc/network/interfaces
}

source <ssinclude StackScriptID="165">
set_hostname
config_iptables
set_security
postfix_install_loopback_only
mysql_install "$DB_PASSWORD" && mysql_tune 40
php_install_with_apache && php_tune
restartServices