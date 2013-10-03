#!/sbin/busybox sh
# Logging
#/sbin/busybox cp /data/user.log /data/user.log.bak
#/sbin/busybox rm /data/user.log
#exec >>/data/user.log
#exec 2>&1

mkdir /data/.siyah
chmod 777 /data/.siyah

. /res/customconfig/customconfig-helper

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.siyah/.ccxmlsum`" ];
then
  rm -f /data/.siyah/*.profile
  echo ${ccxmlsum} > /data/.siyah/.ccxmlsum
fi
[ ! -f /data/.siyah/default.profile ] && cp /res/customconfig/default.profile /data/.siyah

read_defaults
read_config

#cpu undervolting
echo "${cpu_undervolting}" > /sys/devices/system/cpu/cpu0/cpufreq/vdd_levels

if [ "$zram_switch" == "on" ];then

  echo `expr $zram_swappiness \* 1` > /proc/sys/vm/swappiness
  swapoff /dev/block/zram0 > /dev/null 2>&1
  echo 1 > /sys/devices/virtual/block/zram0/reset
  echo `expr $zram_size \* 1024 \* 1024` > /sys/devices/virtual/block/zram0/disksize
  echo `expr $zram_swappiness \* 1` > /proc/sys/vm/swappiness
  mkswap /dev/block/zram0 > /dev/null 2>&1
  swapon /dev/block/zram0 > /dev/null 2>&1
fi

if [ "$zram_switch" == "off" ];then

        swapoff /dev/block/zram0 > /dev/null 2>&1
	umount /dev/block/zram0 > /dev/null 2>&1
	umount /dev/block/zram1 > /dev/null 2>&1
	
fi

#mdnie sharpness tweak
if [ "$mdniemod" == "on" ];then
. /sbin/ext/mdnie-sharpness-tweak.sh
fi

if [ "$logger" == "on" ];then
insmod /lib/modules/logger.ko
fi

# disable debugging on some modules
if [ "$logger" == "off" ];then
  rm -rf /dev/log
  echo 0 > /sys/module/ump/parameters/ump_debug_level
  echo 0 > /sys/module/mali/parameters/mali_debug_level
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys//module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
  echo 0 > /sys/module/alarm/parameters/debug_mask
  echo 0 > /sys/module/alarm_dev/parameters/debug_mask
  echo 0 > /sys/module/binder/parameters/debug_mask
  echo 0 > /sys/module/xt_qtaguid/parameters/debug_mask
fi

# /sbin/busybox sh /sbin/ext/install.sh

##### Early-init phase tweaks #####
# /sbin/busybox sh /sbin/ext/tweaks.sh

/sbin/busybox mount -t rootfs -o remount,ro rootfs

##### EFS Backup #####
(
/sbin/busybox sh /sbin/ext/efs-backup.sh
) &

# apply STweaks defaults
export CONFIG_BOOTING=1
/res/uci.sh apply
export CONFIG_BOOTING=

##### init scripts #####
/sbin/busybox sh /sbin/ext/run-init-scripts.sh
