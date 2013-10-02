#!/bin/bash

TARGET=$1
if [ "$TARGET" != "" ]; then
	echo "starting your build for $TARGET"
else
	echo ""
	echo "you need to define your device target!"
	echo "example: build_sammy.sh n7100"
	exit 1
fi

if [ "$TARGET" = "i9300" ] ; then
CUSTOM_PATH=i9300
MODE=DUAL
else
CUSTOM_PATH=note
MODE=DUAL	
fi

version=SKT_Devil-$TARGET-$MODE-0.37.5_$(date +%Y%m%d)

if [ -e boot.img ]; then
	rm boot.img
fi

if [ -e compile.log ]; then
	rm compile.log
fi

if [ -e ramdisk.cpio.lzma ]; then
	rm ramdisk.cpio.lzma
fi

# Set Default Path
KERNEL_PATH=$PWD

# Set toolchain and root filesystem path
if [ "$(whoami)" == "dominik" ]; then
	#TOOLCHAIN_PATH="/home/dominik/android/android_4.2/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin"
	TOOLCHAIN_PATH="/home/dominik/android/android_4.2/prebuilt/linux-x86/toolchain/android-toolchain-eabi/bin"
	#TOOLCHAIN_PATH="/home/dominik/android/android_4.2/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7.2/bin"
elif [ "$(whoami)" == "rollus" ]; then
	TOOLCHAIN_PATH="/home/rollus/android-toolchain-eabi/bin/"
fi
TOOLCHAIN_PATH="/opt/android-toolchain-eabi-4.8-1309/bin/"
TOOLCHAIN="$TOOLCHAIN_PATH/arm-eabi-"
ROOTFS_PATH="$KERNEL_PATH/ramdisks-skt/$TARGET-combo"
MODULES="$KERNEL_PATH/ramdisks-skt/modules"

defconfig=cyanogenmod_"$TARGET"_defconfig

export KBUILD_BUILD_VERSION="$version"
export KERNELDIR=$KERNEL_PATH

export USE_SEC_FIPS_MODE=true

# Set ramdisk files permissions
chmod 750 $ROOTFS_PATH/roms/*/init*
chmod 644 $ROOTFS_PATH/roms/*/ueventd*
chmod 644 $ROOTFS_PATH/roms/*/lpm.rc
chmod 750 $ROOTFS_PATH/sbin/init*


if [ "$2" = "clean" ]; then
echo "Cleaning latest build"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` mrproper
fi
# Cleaning old kernel and modules
find -name '*.ko' -exec rm -rf {} \;
rm -rf $KERNEL_PATH/arch/arm/boot/zImage

# Making our .config
make $defconfig

scripts/configcleaner "
CONFIG_TARGET_LOCALE_EUR
CONFIG_TARGET_LOCALE_KOR
CONFIG_MACH_C1_KOR_SKT
CONFIG_MACH_C1_KOR_KT
CONFIG_MACH_C1_KOR_LGT
CONFIG_MACH_M0
CONFIG_SEC_MODEM_M0
CONFIG_SEC_MODEM_C1
CONFIG_SEC_MODEM_C1_LGT
CONFIG_USBHUB_USB3503
CONFIG_UMTS_MODEM_XMM6262
CONFIG_LTE_MODEM_CMC221
CONFIG_IP_MULTICAST
CONFIG_LINK_DEVICE_DPRAM
CONFIG_LINK_DEVICE_USB
CONFIG_LINK_DEVICE_HSIC
CONFIG_IPC_CMC22x_OLD_RFS
CONFIG_SIPC_VER_5
CONFIG_SAMSUNG_MODULES
CONFIG_FM
CONFIG_FM_RADIO
CONFIG_FM_SI4709
CONFIG_FM_SI4705
CONFIG_WLAN_REGION_CODE
CONFIG_LTE_VIA_SWITCH
CONFIG_BRIDGE
CONFIG_FM34_WE395
CONFIG_CDMA_MODEM_CBP72
CONFIG_DMA_CMA
CONFIG_DMA_CMA_DEBUG
CONFIG_CMA_SIZE_MBYTES
CONFIG_CMA_SIZE_SEL_MBYTES
CONFIG_CMA_SIZE_SEL_PERCENTAGE
CONFIG_CMA_SIZE_SEL_MIN
CONFIG_CMA_SIZE_SEL_MAX
CONFIG_CMA_ALIGNMENT
CONFIG_CMA_AREAS
CONFIG_TDMB
CONFIG_TDMB_SPI
CONFIG_TDMB_EBI
CONFIG_TDMB_TSIF
CONFIG_TDMB_VENDOR_FCI
CONFIG_TDMB_VENDOR_INC
CONFIG_TDMB_VENDOR_RAONTECH
CONFIG_TDMB_MTV318
CONFIG_TDMB_VENDOR_TELECHIPS
CONFIG_TDMB_SIMUL
CONFIG_TDMB_ANT_DET
CONFIG_ISDBT_FC8100
"
echo "
# CONFIG_TARGET_LOCALE_EUR is not set
CONFIG_TARGET_LOCALE_KOR=y
CONFIG_MACH_C1_KOR_SKT=y
# CONFIG_MACH_C1_KOR_KT is not set
# CONFIG_MACH_C1_KOR_LGT is not set
# CONFIG_MACH_M0 is not set
CONFIG_MACH_C1=y
# CONFIG_SEC_MODEM_M0 is not set
CONFIG_SEC_MODEM_C1=y
CONFIG_MACH_NO_WESTBRIDGE=y
CONFIG_IP_MULTICAST=y
# CONFIG_FM34_WE395 is not set
CONFIG_USBHUB_USB3503=y
# CONFIG_USBHUB_USB3503_OTG_CONN is not set
# CONFIG_UMTS_MODEM_XMM6262 is not set
CONFIG_LTE_MODEM_CMC221=y
CONFIG_LINK_DEVICE_DPRAM=y
CONFIG_LINK_DEVICE_USB=y
# CONFIG_LINK_DEVICE_HSIC is not set
CONFIG_IPC_CMC22x_OLD_RFS=y
CONFIG_SIPC_VER_5=y
# CONFIG_SAMSUNG_MODULES is not set
CONFIG_WLAN_REGION_CODE=201
# CONFIG_LTE_VIA_SWITCH is not set
# CONFIG_SEC_MODEM_C1_LGT is not set
# CONFIG_BRIDGE is not set
# CONFIG_CDMA_MODEM_CBP72 is not set
# CONFIG_FM_RADIO is not set
# CONFIG_FM_SI4709 is not set
# CONFIG_FM_SI4705 is not set
# CONFIG_DMA_CMA is not set
CONFIG_TDMB=y
CONFIG_TDMB_SPI=y
# CONFIG_TDMB_EBI is not set
# CONFIG_TDMB_TSIF is not set
# CONFIG_TDMB_VENDOR_FCI is not set
# CONFIG_TDMB_VENDOR_INC is not set
CONFIG_TDMB_VENDOR_RAONTECH=y
CONFIG_TDMB_MTV318=y
# CONFIG_TDMB_VENDOR_TELECHIPS is not set
# CONFIG_TDMB_SIMUL is not set
# CONFIG_TDMB_ANT_DET is not set
# CONFIG_ISDBT_FC8100 is not set
" >> .config

make -j`grep 'processor' /proc/cpuinfo | wc -l` ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit -1
# Copying and stripping kernel modules
mkdir -p $ROOTFS_PATH/lib/modules
find -name '*.ko' -exec cp -av {} $ROOTFS_PATH/lib/modules/ \;
        for i in $ROOTFS_PATH/lib/modules/*; do $TOOLCHAIN_PATH/arm-eabi-strip --strip-unneeded $i;done;\

# Copy Kernel Image
rm -f $KERNEL_PATH/releasetools-ckh469/$CUSTOM_PATH/tar/$KBUILD_BUILD_VERSION.tar
rm -f $KERNEL_PATH/releasetools-ckh469/$CUSTOM_PATH/zip/$KBUILD_BUILD_VERSION.zip
cp -f $KERNEL_PATH/arch/arm/boot/zImage .


# Create ramdisk.cpio archive
cd $ROOTFS_PATH
find . | cpio -o -H newc > $KERNEL_PATH/ramdisk.cpio
cd $KERNEL_PATH
ls -lh ramdisk.cpio
lzma -9 ramdisk.cpio

# Make boot.img
./mkbootimg --kernel zImage --ramdisk ramdisk.cpio.lzma --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $KERNEL_PATH/boot.img

# Copy boot.img
cp boot.img $KERNEL_PATH/releasetools-ckh469/$CUSTOM_PATH/zip
cp boot.img $KERNEL_PATH/releasetools-ckh469/$CUSTOM_PATH/tar

# Creating flashable zip and tar
cd $KERNEL_PATH
cd releasetools-ckh469/$CUSTOM_PATH/zip
zip -0 -r $KBUILD_BUILD_VERSION.zip *
mkdir -p $KERNEL_PATH/release
mv *.zip $KERNEL_PATH/release
cd ..
cd tar
tar cf $KBUILD_BUILD_VERSION.tar boot.img && ls -lh $KBUILD_BUILD_VERSION.tar
mv *.tar $KERNEL_PATH/release

# Cleanup
cd $KERNEL_PATH
rm $KERNEL_PATH/releasetools-ckh469/$CUSTOM_PATH/zip/boot.img
rm $KERNEL_PATH/releasetools-ckh469/$CUSTOM_PATH/tar/boot.img
rm $KERNEL_PATH/zImage
