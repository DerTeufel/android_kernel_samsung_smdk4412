#!/sbin/busybox sh

extract_payload()
{
  payload_extracted=1
  chmod 755 /sbin/read_boot_headers
  eval $(/sbin/read_boot_headers /dev/block/mmcblk0p5)
  load_offset=$boot_offset
  load_len=$boot_len
  cd /
  dd bs=512 if=/dev/block/mmcblk0p5 skip=$load_offset count=$load_len | tar x
}

. /res/customconfig/customconfig-helper
read_defaults
read_config

mount -o remount,rw /system
/sbin/busybox mount -t rootfs -o remount,rw rootfs
payload_extracted=0

cd /

if [ "$install_root" == "on" ];
then
  if [ -s /system/xbin/su ];
  then
    echo "Superuser already exists"
  else
    if [ "$payload_extracted" == "0" ];then
      extract_payload
    fi
    rm -f /system/bin/su
    rm -f /system/xbin/su
    mkdir /system/xbin
    chmod 755 /system/xbin
    xzcat /res/misc/payload/su.xz > /system/xbin/su
    chown 0.0 /system/xbin/su
    chmod 6755 /system/xbin/su

    rm -f /system/app/*uper?ser.apk
    rm -f /system/app/?uper?u.apk
    rm -f /system/app/*chainfire?supersu*.apk
    rm -f /data/app/*uper?ser.apk
    rm -f /data/app/?uper?u.apk
    rm -f /data/app/*chainfire?supersu*.apk
    rm -rf /data/dalvik-cache/*uper?ser.apk*
    rm -rf /data/dalvik-cache/*chainfire?supersu*.apk*
    xzcat /res/misc/payload/Superuser.apk.xz > /system/app/Superuser.apk
    chown 0.0 /system/app/Superuser.apk
    chmod 644 /system/app/Superuser.apk
  fi
fi;

echo "Checking if STweaks is installed"
#stmd5sum=`/sbin/busybox md5sum /system/app/STweaks.apk | /sbin/busybox awk '{print $1}'`
#if [ "$stmd5sum" == "0936a23cbcf1092be8fba4a8905fcd22" ];then
#installstweaks=1
#fi

#if [ ! -f /system/.siyah/stweaks-installed ]; then
#installstweaks=1
#fi

#if [ "$installstweaks" == "1" ];then
#  rm /system/app/STweaks.apk
#  rm -f /data/app/com.gokhanmoral.STweaks*
#  rm -f /data/dalvik-cache/*STweaks.*
#  rm -f /data/app/com.gokhanmoral.stweaks*
#  rm -f /data/dalvik-cache/*stweaks*
#
#  cat /res/STweaks.apk > /system/app/STweaks.apk
#  chown 0.0 /system/app/STweaks.apk
#  chmod 644 /system/app/STweaks.apk
#  mkdir /system/.siyah
#  chmod 755 /system/.siyah
#  echo 1 > /system/.siyah/stweaks-installed
#fi
echo "ntfs-3g..."
if [ ! -s /system/xbin/ntfs-3g ];
then
  if [ "$payload_extracted" == "0" ];then
    extract_payload
  fi
  xzcat /res/misc/payload/ntfs-3g.xz > /system/xbin/ntfs-3g
  chown 0.0 /system/xbin/ntfs-3g
  chmod 755 /system/xbin/ntfs-3g
fi

rm -rf /res/misc/payload

/sbin/busybox mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system
