#!/bin/bash

###########################################################
# utilitary functions
###########################################################

function mclean {
	echo "cleaning..."
	unset -f srcami
	unset UNAME
	unset ROOT_PATH
	unset READLINK
	unset LIB_PATH
	#set +e # Exit if any command returns non-zero.
}
