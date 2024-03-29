#!/bin/bash
source "$LIB_PATH/utils.sh"
source "$LIB_PATH/hostname.sh"
source "$LIB_PATH/user.sh"
source "$LIB_PATH/security.sh"

function defaults_basic {
	#TODO: verify if vars are set and then use defautls our get 'em another way
	HOST_NAME="myhost"
	USER_NAME="myuser"
	USER_PASSWORD="mys3cr3t"
	USER_SSH_KEY="ssh-rsa paste here your ~/.ssh/id_rsa.pub"
}

function install_basic {
	upgrade_system
	install_essentials
	set_hostname $HOST_NAME
	update_locale_en_US_UTF_8
	create_deploy_user $USER_NAME $USER_PASSWORD "$USER_SSH_KEY"
	set_basic_security
}