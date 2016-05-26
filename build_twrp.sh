#!/bin/bash

#export USE_CCACHE=1
#export CCACHE_DIR=~/.ccache
#for jenkins

PRODUCT=$1

TWRP_VER=`cat $(pwd)/bootable/recovery-twrp/variables.h |grep TW_VERSION_STR | awk '{print $3;}' |sed -e s/\"//g`
BIN_NAME=twrp-$TWRP_VER-$PRODUCT

  CL_RED="\033[31m"
  CL_GRN="\033[32m"
  CL_YLW="\033[33m"
  CL_BLU="\033[34m"
  CL_MAG="\033[35m"
  CL_CYN="\033[36m"
  CL_RST="\033[0m"

export TARGET_RECOVERY=twrp
export OUT_DIR=$(pwd)/out_twrp
#export OUT_DIR_COMMON_BASE=out_twrp

PRODUCT_CONF=vendor/aojp/products/${PRODUCT}.conf
if [ ! -e ${PRODUCT_CONF} ]; then
  echo -e "\033[0;31m${PRODUCT_CONF} is not found.\033[0;39m"
  echo "Usage: build.sh [product name]"
  echo "  - [product name] is available below :"
  echo -e "\033[0;36m"'    '`ls -1 vendor/aojp/products/ | cut -d . -f1`"\033[0;39m"
  exit -1
fi


if [ -d $OUT_DIR/target/product/$PRODUCT ]; then
	rm -rf $OUT_DIR/target/product/$PRODUCT
fi

./build.sh $PRODUCT recoveryimage ${@:2}

if [ "TARGET_ODIN3_AVAILABLE" == "y" ]; then
	cd $OUT_DIR/target/product/$PRODUCT

	if [ -f recovery.img ];then
		echo -e ${CL_CYN}"----- Making odin3 recovery tar.md5 ------"${CL_RST}

		tar cf $BIN_NAME-odin.tar recovery.img
		md5sum -t $BIN_NAME-odin.tar >> $BIN_NAME-odin.tar
		mv $BIN_NAME-odin.tar $BIN_NAME-odin.tar.md5
		echo -e ${CL_CYN}"Made odin3 tar.md5: $OUT_DIR/target/product/$PRODUCT/$BIN_NAME-odin.tar.md5"${CL_RST}
		echo ""
		echo -e ${CL_GRN}"#### make completed successfully ####"${CL_RST}
		echo ""
	fi
	cd -
fi

