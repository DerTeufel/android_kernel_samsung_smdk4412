#!/sbin/busybox sh
BB="/sbin/busybox"
$BB mount -t ext4 -o rw /dev/block/mmcblk0p10 /cache
$BB date >/cache/system_mount.txt
exec >>/cache/system_mount.txt 2>&1

echo "first mount:"
$BB mount
echo ""

$BB ls -l /.secondrom
echo ""

$BB ls -l /.secondrom
echo ""
$BB mount -t ext4 -o rw /dev/block/mmcblk0p12 /.secondrom

#### system
$BB mkdir -p /system
$BB losetup /dev/block/loop0 /.secondrom/media/.secondrom/system.img
$BB mount -t ext4 -o ro /.secondrom/media/.secondrom/system.img /system

echo ""
$BB mount

