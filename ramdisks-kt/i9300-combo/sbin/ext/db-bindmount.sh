#!/sbin/busybox sh

mkdir -p /.secondrom/media/.secondrom/data
mount --bind /.secondrom/media/.secondrom/data /data
mkdir /data/media
mount --bind /.secondrom/media /data/media
