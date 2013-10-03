#!/sbin/busybox sh

# remount partitions with noatime
for k in $(mount | grep relatime | cut -d " " -f3);
do
mount -o remount,noatime,nodiratime,noauto_da_alloc,barrier=0 $k
done;

echo 256 > /sys/block/mmcblk0/bdi/read_ahead_kb
echo 512 > /sys/block/mmcblk1/bdi/read_ahead_kb

#enable kmem interface for everyone
echo 0 > /proc/sys/kernel/kptr_restrict

#disable cpuidle log
echo 0 > /sys/module/cpuidle_exynos4/parameters/log_en

# replace kernel version info for repacked kernels
#cat /proc/version | grep infra && (k=15;for i in 83 105 121 97 104 45 49 46 54 98 49 48;do kmemhelper -t char -n linux_proc_banner -o $k $i;k=`expr $k + 1`;done;)
cat /proc/version | grep infra && (kmemhelper -t string -n linux_proc_banner -o 15 `cat /res/version`)

# sched_mc -> 2 
# "to provide better performance in a underutilised system...
# "...by keeping the group of tasks on a single cpu package...
# "...facilitating cache sharing and reduced off-chip traffic"
echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

# enable AFTR
echo 3 > /sys/module/cpuidle_exynos4/parameters/enable_mask

# pegasusq tweaks
echo 20000 > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_rate
echo 20 > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_up_rate
echo 40 > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_down_rate
echo 500000 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_1_1
echo 200000 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_0
echo 600000 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_1
echo 300000 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_3_0
echo 700000 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_3_1
echo 400000 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_4_0
echo 150 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_1_1
echo 150 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_0
echo 300 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_1
echo 300 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_3_0
echo 400 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_3_1
echo 400 > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_4_0
echo 2 > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_down_factor
echo 37 > /sys/devices/system/cpu/cpufreq/pegasusq/freq_step

# process priority modifications
# (
# for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20;do
# sleep 5;
# renice 15 `pidof kswapd0`;
# renice -3 `pidof android.process.acore`;
# renice 3 `pidof android.process.media`;
# renice -10 `pidof com.sec.android.app.launcher`;
# renice -10 `pidof com.anddoes.launcher`;
# renice -10 `pidof com.teslacoilsw.launcher`;
# renice -10 `pidof com.sec.android.inputmethod`;
# renice -10 `pidof com.cootek.smartinputv5`;
# renice -10 `pidof com.swype.android.inputmethod`;
# done;
# )&

