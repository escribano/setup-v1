#!/usr/bin/env bash
#
# System Functions Library
#
# Does nothing on its own. Do not deploy directly.
#
# https://www.linode.com/stackscripts/view/?StackScriptID=3687
#
# * VARIABLES *
#
# WORK_DIR
# HARDWARE_ARCHITECTURE
# SYSTEM_ARCHITECTURE
# SYSTEM_DISTRIBUTION
# SYSTEM_RELEASE
# SYSTEM_CODENAME
#
#
# * LOGGING FUNCTIONS *
#
# stackscript_log
# - Starts logging output to root folder
#
#
# * SYSTEM FUNCTIONS *
#
# set_hostname "hostname"
# - Set the systems hostname
#
# set_timezone "timezone"
# - Set the systems timezone
#
# add_hosts "1.2.3.4" "test domain"
# - Add IP and Host(s) to /etc/hosts
#
#
# * REPOSITORY FUNCTIONS *
#
# apt_ppa_add "ppa:id/name" "key"
# - Add PPA to package sources & optionaly sign with key
#
# apt_sources_add "type" "uri" "distribution" "components" ["list file"]
# - Add repository to sources
#
# apt_sources_key_add "uri"
# - Add repository key
#
# apt_update
# - Performs system update
#
# apt_upgrade
# - Performs system upgrade
#
# apt_upgrade_full
# - Performs full system update
#
# apt_install "install pkg names"
# - Install package with apt-get
#
#
# * DOWNLOAD FUNCTIONS *
#
# wget_as "remote resource" "save location"
# - Download a resource and save to location
#
#
# * MAIL FUNCTIONS *
#
# send_email "from" "to" "subject" "message" ["message type"]
# - Send an email


###############
## VARIABLES ##
###############

WORK_DIR=$(pwd)

HARDWARE_ARCHITECTURE=$(uname -m)

SYSTEM_ARCHITECTURE=$(uname -i)
SYSTEM_DISTRIBUTION=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
SYSTEM_RELEASE=$(lsb_release -sr)
SYSTEM_CODENAME=$(lsb_release -sc)


#######################
## LOGGING FUNCTIONS ##
#######################

stackscript_log() {
    exec > >(tee -a /root/stackscript.log)
    exec 2> >(tee -a /root/stackscript.err)
}


######################
## SYSTEM FUNCTIONS ##
######################

set_hostname() {
    # Set the systems hostname
    # $1 = the hostname

    if [ ! -n "$1" ]; then
        echo "set_hostname() requires the hostname as its first argument"
        return 1;
    fi

    echo "$1" > /etc/hostname
    hostname -F /etc/hostname
}

set_timezone() {
    # Set the systems timezone
    # $1 = the timezone

    if [ ! -n "$1" ]; then
        echo "set_timezone() requires the timezone as its first argument"
        return 1;
    fi

    echo "$1" > /etc/timezone                     
    cp "/usr/share/zoneinfo/$1" "/etc/localtime"
}

add_hosts() {
    # Add IP and Host(s) to /etc/hosts
    # $1 = IP address
    # $2 = doman(s) separated by spaces

    if [ ! -n "$1" ]; then
        echo "add_hosts() requires an IP address as its first argument"
        return 1;
    elif [ ! -n "$2" ]; then
        echo "add_hosts() requires one or more domains as its second argument"
        return 1;
    fi

    echo "$1	$2" >> /etc/hosts
}


##########################
## REPOSITORY FUNCTIONS ##
##########################

apt_ppa_add() {
    # Add PPA to package sources & optionaly sign with key
    # $1 = PPA to add
    # $2 = [OPTIONAL] PPA Key

    if [ ! -n "$1" ]; then
        echo "apt_ppa_add() requires the PPA as its first argument"
        return 1;
    elif [ -a "/usr/bin/add-apt-repository" ]; then 
        apt_install add-apt-repository
    fi

    add-apt-repository "$1"

    if [ -n "$2" ]; then
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$2"
    fi

    apt_upgrade
}

apt_sources_add() {
    # Add repository to sources
    # $1 = Type [binary,source]
    # $2 = URI
    # $3 = Distribution
    # $4 = Components
    # $5 = [optional] List file name

    if [ ! -n "$1" ]; then
        echo "apt_sources_add() requires the repository type as its first argument"
        return 1;
    elif [ ! -n "$2" ]; then
        echo "apt_sources_add() requires the repository URI as its second argument"
        return 1;
    elif [ ! -n "$3" ]; then
        echo "apt_sources_add() requires the repository distribution as its third argument"
        return 1;
    elif [ ! -n "$4" ]; then
        echo "apt_sources_add() requires the repository components as its fourth argument"
        return 1;
    fi

    SOURCE="deb"

    if [ "$1" == "source" ]; then
        SOURCE="$SOURCE-src"
    elif [ "$1" != "binary" ]; then
        echo "apt_sources_add() requires the repository type as its first argument"
        return 1;
    fi

    SOURCE="$SOURCE $2 $3 $4"

    if [ ! -n "$5" ]; then
        echo "$SOURCE" >> "/etc/apt/sources.list"
    else
        echo "$SOURCE" > "/etc/apt/sources.list.d/$5.list"
    fi
}

apt_sources_key_add() {
    # Add repository key
    # $1 = URI

    if [ ! -n "$1" ]; then
        echo "apt_sources_key_add() requires the repository key URI as its first argument"
        return 1;
    fi

    wget -O- "$1" | sudo apt-key add -
}

apt_update() {
    # Performs system update

    apt-get update
}

apt_upgrade() {
    # Performs system upgrade

    apt_update

    apt-get -y upgrade
}

apt_upgrade_full() {
    # Performs full system update

    apt_update

    if [ -a "/usr/bin/aptitude" ]; then 
        apt_install aptitude
    fi

    aptitude -y full-upgrade
}

apt_install() {
    # Install package with apt-get
    # $1 = Package(s) separated by spaces

    if [ ! -n "$1" ]; then
        echo "apt_install() requires one or more packages as its first argument"
        return 1;
    fi

    apt-get -y install "$1"
}


########################
## DOWNLOAD FUNCTIONS ##
########################

wget_as() {
    # Download a resource and save to location
    # $1 = Resource to download
    # $2 = Location to save resource

    if [ ! -n "$1" ]; then
        echo "wget_as() requires a resource to downlad as its first argument"
        return 1;
    elif [ ! -n "$2" ]; then
        echo "wget_as() requires a location to save resource as its second argument"
        return 1;
    fi

    wget --output-document="$2" "$1"
}


####################
## MAIL FUNCTIONS ##
####################

send_email() {
    # Send an email
    # $1 = From
    # $2 = To
    # $3 = Subject
    # $4 = Message
    # $5 = Message Type

    if [ ! -n "$1" ]; then
        echo "sendmail() requires a from email address as its first argument"
        return 1;
    elif [ ! -n "$2" ]; then
        echo "sendmail() requires a to email address as its second argument"
        return 1;
    elif [ ! -n "$3" ]; then
        echo "sendmail() requires a subject as its third argument"
        return 1;
    elif [ ! -n "$4" ]; then
        echo "sendmail() requires a message as its forth argument"
        return 1;
    fi

    if [ ! -n "$5" ]; then
        MESSAGE_TYPE="text/plain"
    else
        MESSAGE_TYPE="$5"
    fi

    CONTENT="to: $2
from: $1
subject: $3
mime-version: 1.0
content-type: $MESSAGE_TYPE

$4
"

    echo "$CONTENT" | sendmail -i -t
}