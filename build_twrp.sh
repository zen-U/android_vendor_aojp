#!/bin/bash

#export USE_CCACHE=1
#export CCACHE_DIR=~/.ccache
#for jenkins

PRODUCT=$1

export TARGET_RECOVERY=twrp
export TWRP_VERSION=`cat $(pwd)/bootable/recovery-twrp/variables.h |grep TW_VERSION_STR | awk '{print $3;}' |sed -e s/\"//g`
./build.sh $PRODUCT recoveryimage ${@:2}
