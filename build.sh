#!/bin/bash

PRODUCT=$1
MAKE_TARGET=$2

PRODUCT_CONF=vendor/aojp/products/${PRODUCT}.conf
if [ ! -e ${PRODUCT_CONF} ]; then
  echo "${PRODUCT_CONF} is not found."
  echo "Usage: build.sh [product name]"
  exit -1
fi

# common
export CM_BUILDTYPE=AOJP

# import product config
. ${PRODUCT_CONF}

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
  make ${MAKE_TARGET} -j4
fi
