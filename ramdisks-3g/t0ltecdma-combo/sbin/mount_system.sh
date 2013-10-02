#!/sbin/busybox sh
BB="/sbin/busybox"
$BB mount -t ext4 -o rw /dev/block/mmcblk0p14 /cache
$BB date >/cache/system_mount.txt
exec >>/cache/system_mount.txt 2>&1

if $BB [ -d /sys/dev/block/259:1 ] ; then
   BLOCKDEVICE=mmcblk0p17
else
   BLOCKDEVICE=mmcblk0p16
fi

echo "first mount:"
$BB mount
echo ""

$BB ls -l /.secondrom
echo ""

$BB ls -l /.secondrom
echo ""
$BB mount -t ext4 -o rw /dev/block/$BLOCKDEVICE /.secondrom

#### system
$BB mkdir -p /system
$BB losetup /dev/block/loop0 /.secondrom/media/.secondrom/system.img
$BB mount -t ext4 -o ro /.secondrom/media/.secondrom/system.img /system

echo ""
$BB mount

