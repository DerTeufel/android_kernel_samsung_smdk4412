#!/sbin/busybox sh
BB="/sbin/busybox"
$BB date >/cache/mount.txt
exec >>/cache/mount.txt 2>&1

DEBUG_FILE=/cache/dmesg.txt
DEBUG_FILE_LOGCAT=/cache/logcat.txt

$BB cp /boot.txt /cache/boot.txt

SEPARATOR() {
	echo "" >> $DEBUG_FILE;
	echo " ---------------------------- " >> $DEBUG_FILE;
	echo "" >> $DEBUG_FILE;
}

dmesg_log() {
	(# dmesg
	echo "dmesg-Info:" > $DEBUG_FILE;
	dmesg >> $DEBUG_FILE;
	SEPARATOR;
	echo "dmesg-Error:" >> $DEBUG_FILE;
	dmesg | grep -i "Error" >> $DEBUG_FILE;
	)&
}

logcat_log() {
	(# logcat
	echo "logcat-Info:" > $DEBUG_FILE_LOGCAT;
	system/bin/logcat -f $DEBUG_FILE_LOGCAT;
	wait 120;
	pkill logcat;
	)&
}


check_mount () {
for i in $($BB seq 1 5) ; do
if $BB test -d /sys/dev/block/179:9 ; then
break
else
echo "Waiting for internal mmc..."
echo $i;
$BB sleep 1
fi
done
}

echo "first mount:"
$BB mount
echo ""

#check_mount

#### data
$BB mkdir -p /.secondrom/media/.secondrom/data
$BB mount --bind /.secondrom/media/.secondrom/data /data
$BB mkdir -p /data/media
$BB mount --bind /.secondrom/media /data/media

if $BB [ -d /data/media/0 ]; then
	echo "preparing layout_version"
	echo 2 > /data/.layout_version
fi

echo "permissions of data/media"
$BB chown media_rw.media_rw /data/media
$BB chown -R media_rw.media_rw /data/media/*

echo ""
$BB mount

logcat_log
dmesg_log

