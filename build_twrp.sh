#!/bin/bash

#export USE_CCACHE=1
#export CCACHE_DIR=~/.ccache
#for jenkins

PRODUCT=$1

export TARGET_RECOVERY=twrp
./build.sh $PRODUCT recoveryimage ${@:2}
