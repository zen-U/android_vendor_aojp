#!/bin/bash

PRODUCT=$1
OUT=out/target/product/$PRODUCT
cur=`pwd`

print_red()
{
echo -e "\033[0;31m$1\033[0;39m"
}
print_cyan()
{
echo -e "\033[0;36m$1\033[0;39m"
}


if [ -z "$PRODUCT" ]
then
	print_red "error:"
    print_red "$0 [device_name]"
    exit 1
fi

if [ ! -f "$OUT/recovery.img" ]
then
	print_red "error:"
    print_red "recovery.img is not built."
    print_red "please run make recoveryimage first"
    exit 1
fi



UTILITIES_DIR=$OUT/utilities
RECOVERY_DIR=$UTILITIES_DIR/recovery
SCRIPT_DIR=$RECOVERY_DIR/META-INF/com/google/android
mkdir -p $SCRIPT_DIR


#make the version strings
VERSION=$(cat bootable/recovery/Android.mk | grep RECOVERY_VERSION | grep RECOVERY_NAME | awk '{ print $4 }')
KBC_REV=$(cat bootable/recovery/Android.mk | grep RECOVERY_KBC_REV | grep := | awk '{ print $3 }')
RELEASE_VERSION=${VERSION}_${KBC_REV}


TEMPLATE="vendor/aojp/release-tools/updater-script-recovery.sed"
PARTITION=`grep "\/recovery" "$OUT/recovery/root/etc/recovery.fstab" | cut -d " " -f1 | sed -e s/"\/"/"\\\\\\\\\/"/g`
BUILDER=`who | cut -d " " -f1`

SIGNAPK=`find ./out | grep signapk.jar`
KEY_DIR=build/target/product/security

IMAGE_NAME=$PRODUCT-KK-KBC-CWM-${RELEASE_VERSION}-recovery
SIGNED_ZIP=$UTILITIES_DIR/$IMAGE_NAME-singed.zip

echo RELEASE_VERSION=$RELEASE_VERSION
echo BUILDER=$BUILDER
#echo PARTITION=$PARTITION

#copy binaries
cp $OUT/system/bin/updater $SCRIPT_DIR/update-binary
cp $OUT/recovery.img $RECOVERY_DIR/recovery.img

#make script
echo make updater script
sed -e "s/@VERSION/$RELEASE_VERSION/g" $TEMPLATE |\
sed -e "s/@BUILDER/$BUILDER/g" | \
sed -e "s/@PARTATION/$PARTITION/g" > $SCRIPT_DIR/updater-script

#make update zip
echo make update zip
cd $RECOVERY_DIR && zip -rq ../unsigned.zip . && cd $cur

echo make cwm-singned zip
java -jar $SIGNAPK -w $KEY_DIR/testkey.x509.pem $KEY_DIR/testkey.pk8 $UTILITIES_DIR/unsigned.zip $SIGNED_ZIP
#make odin tar
cp $OUT/recovery.img $UTILITIES_DIR/

cd $UTILITIES_DIR && tar cf $IMAGE_NAME.tar recovery.img && cd $cur

#make raw binary
cd $UTILITIES_DIR && mv recovery.img $IMAGE_NAME.img && cd $cur

#copy to out
#cp $UTILITIES_DIR/$IMAGE_NAME* $OUT

#cleanup
#rm $UTILITIES_DIR/unsigned.zip

print_cyan "$IMAGE_NAME is now available at $UTILITIES_DIR/"
