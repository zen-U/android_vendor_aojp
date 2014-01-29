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

TEMPLATE="vendor/aojp/release-tools/updater-script-recovery.sed"
TEMPLATE_LOKI="vendor/aojp/release-tools/updater-script-loki-recovery.sed"

UTILITIES_DIR=$OUT/utilities
RECOVERY_DIR=$UTILITIES_DIR/recovery
SCRIPT_DIR=$RECOVERY_DIR/META-INF/com/google/android
mkdir -p $SCRIPT_DIR


#make the version strings
VERSION=$(cat bootable/recovery/Android.mk | grep RECOVERY_VERSION | grep RECOVERY_NAME | awk '{ print $4 }')
KBC_REV=$(cat bootable/recovery/Android.mk | grep RECOVERY_KBC_REV | grep := | awk '{ print $3 }')
RELEASE_VERSION=${VERSION}_${KBC_REV}

PARTITION=`grep "\/recovery" "$OUT/recovery/root/etc/recovery.fstab" | cut -d " " -f1 | sed -e s/"\/"/"\\\\\\\\\/"/g`
BUILDER=`who | cut -d " " -f1`

SIGNAPK=`find ./out | grep signapk.jar`
KEY_DIR=build/target/product/security

IMAGE_NAME=$PRODUCT-KK-KBC-CWM-${RELEASE_VERSION}-recovery
SIGNED_ZIP=$UTILITIES_DIR/$IMAGE_NAME-singed.zip

copy_binaries()
{
	cp $OUT/system/bin/updater $SCRIPT_DIR/update-binary
	cp $OUT/recovery.img $RECOVERY_DIR/recovery.img
}
copy_binaries_loki()
{
	if [ -f $OUT/system/etc/loki_bootloaders ]
	then
		cp $OUT/system/etc/loki_bootloaders $RECOVERY_DIR/loki_bootloaders
		cp $OUT/system/etc/unlocked_bootloaders $RECOVERY_DIR/unlocked_bootloaders
		cp $OUT/system/bin/loki_patch $RECOVERY_DIR/loki_patch
		cp $OUT/system/bin/loki_flash $RECOVERY_DIR/loki_flash
		cp $OUT/system/bin/loki.sh $RECOVERY_DIR/loki.sh
	fi
}

#make script
make_update_script()
{
	_TEMPLATE=$1
	echo make updater script
	sed -e "s/@VERSION/$RELEASE_VERSION/g" $_TEMPLATE |\
	sed -e "s/@BUILDER/$BUILDER/g" | \
	sed -e "s/@PARTATION/$PARTITION/g" > $SCRIPT_DIR/updater-script
}

#make update zip
make_update_zip()
{
	echo make update zip
	cd $RECOVERY_DIR && zip -rq ../unsigned.zip . && cd $cur

	echo make cwm-singned zip
	java -jar $SIGNAPK -w $KEY_DIR/testkey.x509.pem $KEY_DIR/testkey.pk8 $UTILITIES_DIR/unsigned.zip $SIGNED_ZIP
}
#make odin tar
make_odin_tar()
{
	echo make Odin3 tar
	cp $OUT/recovery.img $UTILITIES_DIR/
	cd $UTILITIES_DIR
	tar cf $IMAGE_NAME-odin.tar recovery.img
    md5sum -t $IMAGE_NAME-odin.tar >> $IMAGE_NAME-odin.tar
    mv $IMAGE_NAME-odin.tar $IMAGE_NAME-odin.tar.md5
	cd $cur
}

#make raw binary
rename_raw()
{
	cd $UTILITIES_DIR && mv recovery.img $IMAGE_NAME.img && cd $cur
}

#copy to out
#cp $UTILITIES_DIR/$IMAGE_NAME* $OUT

cleanup()
{
	#rm $UTILITIES_DIR/unsigned.zip
	echo .
}

get_script_template()
{
	if [ -f $OUT/system/etc/loki_bootloaders ]
	then
		echo $TEMPLATE_LOKI
	else
		echo $TEMPLATE
	fi
}

#loki_patch()
#{
#	if [ -f out/host/linux-x86/bin/loki_patch ]
#	then
#		gcc -o device/samsung/msm8960-common/loki/loki_patch.c out/host/linux-x86/bin/loki_patch
#	else
#		echo $TEMPLATE
#	fi
#	out/host/linux-x86/bin/loki_patch recovery ./aboot.img /tmp/boot.img $C/boot.lok
#}

#----------------------------------------------------
#main process
#----------------------------------------------------
echo RELEASE_VERSION=$RELEASE_VERSION
echo BUILDER=$BUILDER
#echo PARTITION=$PARTITION

copy_binaries
copy_binaries_loki
script_template=`get_script_template`
make_update_script $script_template
make_update_zip

if [ $script_template == $TEMPLATE ]
then 
	make_odin_tar
	rename_raw
fi
cleanup

print_cyan "$IMAGE_NAME is now available at $UTILITIES_DIR/"
