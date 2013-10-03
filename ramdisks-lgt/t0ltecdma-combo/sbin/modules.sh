#!/sbin/busybox sh

$BB date >>modules.txt
exec >>modules.txt 2>&1

#  try ko files for exfat

if [ -f /system/lib/modules/exfat_core.ko ] ; then
    insmod /system/lib/modules/exfat_core.ko
    insmod /system/lib/modules/exfat_fs.ko
fi

if [ -f /lib/modules/exfat_core.ko ] ; then
    insmod /lib/modules/exfat_core.ko
    insmod /lib/modules/exfat_fs.ko
fi
