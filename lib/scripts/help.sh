#!/bin/bash

# https://www.linode.com/stackscripts/view/?StackScriptID=1383

destdir=/opt

aptitude -y install git-core

mkdir -p ${destdir}
git clone git://github.com/help/setup.git ${destdir}/setup