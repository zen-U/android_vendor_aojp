#!/bin/bash

PRODUCT=$1
MAKE_TARGET=$2

PRODUCT_CONF=vendor/aojp/products/${PRODUCT}.conf
if [ ! -e ${PRODUCT_CONF} ]; then
  echo -e "\033[0;31m${PRODUCT_CONF} is not found.\033[0;39m"
  echo "Usage: build.sh [product name]"
  echo "  - [product name] is available below :"
  echo -e "\033[0;36m"'    '`ls -1 vendor/aojp/products/ | cut -d . -f1`"\033[0;39m"
  exit -1
fi

# common
export CM_BUILDTYPE=AOJP
export KBUILD_BUILD_HOST=kbc

# import product config
. ${PRODUCT_CONF}

if [ "$TARGET_RECOVERY" == "twrp" ]; then
    export PLATFORM_SDK_VERSION=23
fi

echo "========================================================================="
echo " PRODUCT : ${PRODUCT}"
echo "   CM_BUILDTYPE : ${CM_BUILDTYPE}"
echo "   TARGET_RECOVERY : ${TARGET_RECOVERY}"
echo "   PRODUCT_PREBUILT_WEBVIEWCHROMIUM : ${PRODUCT_PREBUILT_WEBVIEWCHROMIUM}"
if [ ! "${MAKE_TARGET}" ]; then
echo "   MAKE_TARGET : all"
else
echo "   MAKE_TARGET : ${MAKE_TARGET}"
fi
echo "========================================================================="

. build/envsetup.sh

if [ ! "${MAKE_TARGET}" ]; then
  brunch ${PRODUCT}
else
  choosecombo release cm_${PRODUCT} userdebug
  make ${MAKE_TARGET} -j4  ${@:3}
fi
