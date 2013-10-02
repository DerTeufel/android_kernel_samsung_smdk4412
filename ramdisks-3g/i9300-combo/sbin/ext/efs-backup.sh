#!/sbin/busybox sh
if [ ! -f /data/.siyah/efsbackup.tar.gz ];
then
  mkdir /data/.siyah
  chmod 777 /data/.siyah
  /sbin/busybox tar zcvf /data/.siyah/efsbackup.tar.gz /efs
  /sbin/busybox cat /dev/block/mmcblk0p3 > /data/.siyah/efsdev-mmcblk0p3.img
  /sbin/busybox gzip /data/.siyah/efsdev-mmcblk0p3.img
  /sbin/busybox cp /data/.siyah/efs* /data/media
  chmod 777 /data/media/efsdev-mmcblk0p3.img
  chmod 777 /data/media/efsbackup.tar.gz
fi

