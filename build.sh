#!/bin/bash

PRODUCT=$1
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
echo "========================================================================="

. build/envsetup.sh
brunch ${PRODUCT}
