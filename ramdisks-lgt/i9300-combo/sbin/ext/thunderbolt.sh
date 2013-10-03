#!/sbin/busybox sh
#ThunderBolt!
#Credits:
# zacharias.maladroit
# voku1987
# collin_ph@xda
# TAKE NOTE THAT LINES PRECEDED BY A "#" IS COMMENTED OUT!

# ==============================================================
# ==============================================================
# ==============================================================
# I/O related tweaks 
# ==============================================================
# ==============================================================
# ==============================================================

STL=`ls -d /sys/block/stl*`;
BML=`ls -d /sys/block/bml*`;
MMC=`ls -d /sys/block/mmc*`;
ZRM=`ls -d /sys/block/zram*`;
MTD=`ls -d /sys/block/mtd*`;


#I/O scheduler (Commented out) An example here is NOOP. SIO is still the best ;)
#for i in $STL $BML $MMC;
#do
#	echo "noop" > $i/queue/scheduler; 
#done;

# Optimize non-rotating storage; 
for i in $STL $BML $MMC $ZRM $MTD;
do
	#IMPORTANT!
	if [ -e $i/queue/rotational ]; 
	then
		echo 0 > $i/queue/rotational; 
	fi;
	if [ -e $i/queue/nr_requests ];
	then
		echo 8192 > $i/queue/nr_requests; # for starters: keep it sane
	fi;
	#CFQ specific
	if [ -e $i/queue/iosched/back_seek_penalty ];
	then 
		echo 1 > $i/queue/iosched/back_seek_penalty;
	fi;
	#CFQ specific
	if [ -e $i/queue/iosched/low_latency ];
	then
		echo 1 > $i/queue/iosched/low_latency;
	fi;
	#CFQ Specific
	if [ -e $i/queue/iosched/slice_idle ];
	then 
		echo 1 > $i/queue/iosched/slice_idle; # previous: 1
	fi;
	# deadline/VR/SIO scheduler specific
	if [ -e $i/queue/iosched/fifo_batch ];
	then
		echo 4 > $i/queue/iosched/fifo_batch;
	fi;
	if [ -e $i/queue/iosched/writes_starved ];
	then
		echo 1 > $i/queue/iosched/writes_starved;
	fi;
	#CFQ specific
	if [ -e $i/queue/iosched/quantum ];
	then
		echo 8 > $i/queue/iosched/quantum;
	fi;
	#VR Specific
	if [ -e $i/queue/iosched/rev_penalty ];
	then
		echo 1 > $i/queue/iosched/rev_penalty;
	fi;
	if [ -e $i/queue/rq_affinity ];
	then
	echo "1"   >  $i/queue/rq_affinity;   
	fi;
#disable iostats to reduce overhead  # idea by kodos96 - thanks !
	if [ -e $i/queue/iostats ];
	then
		echo "0" > $i/queue/iostats;
	fi;
# Optimize for read- & write-throughput; 
# Optimize for readahead; 
	if [ -e $i/queue/read_ahead_kb ];
	then
		echo "256" >  $i/queue/read_ahead_kb;
	fi;
# Commented out nomerges (Merges are good). max_sectors_kb to default - don't tweak it
#          echo "0"   >  $i/queue/nomerges
#          echo "128" >  $i/queue/max_sectors_kb
	
done;
# Specifically for NAND devices where reads are faster than writes, writes starved 2:1 is good
for i in $STL $BML $ZRM $MTD;
do
	if [ -e $i/queue/iosched/writes_starved ];
	then
		echo 2 > $i/queue/iosched/writes_starved;
	fi;
done;



# =========
# TWEAKS: raising read_ahead_kb cache-value for mounts that are sdcard-like to 1024 
# =========

if [ -e /sys/devices/virtual/bdi/179:0/read_ahead_kb ];
then
    echo "1024" > /sys/devices/virtual/bdi/179:0/read_ahead_kb;
fi;
	
if [ -e /sys/devices/virtual/bdi/179:16/read_ahead_kb ];
  then
    echo "1024" > /sys/devices/virtual/bdi/179:16/read_ahead_kb;
fi;

if [ -e /sys/devices/virtual/bdi/179:32/read_ahead_kb ];
  then
    echo "1024" > /sys/devices/virtual/bdi/179:32/read_ahead_kb;
fi;

if [ -e /sys/devices/virtual/bdi/179:48/read_ahead_kb ];
  then
    echo "1024" > /sys/devices/virtual/bdi/179:48/read_ahead_kb;
fi;

if [ -e /sys/devices/virtual/bdi/default/read_ahead_kb ];
  then
    echo "256" > /sys/devices/virtual/bdi/default/read_ahead_kb;
fi;


# Remount all partitions with noatime
for k in $(busybox mount | grep relatime | cut -d " " -f3);
do
#sync;
busybox mount -o remount,noatime $k;
done;


# ==============================================================
# ==============================================================
# ==============================================================
# VFS, VM settings
# ==============================================================
# ==============================================================
# ==============================================================


# Don't optimize swappiness. Swappiness does nothing if you don't have ZCACHE 
#echo 0 > /proc/sys/vm/swappiness # 70 for zram, Talon # 0 for CM7 / MIUI (no zram yet)

#sysctl -w vm.page-cluster=3;
#sysctl -w vm.laptop_mode=0;
#sysctl -w vm.dirty_expire_centisecs=3000;
#sysctl -w vm.dirty_writeback_centisecs=500;
#sysctl -w vm.dirty_background_ratio=40;
#sysctl -w vm.dirty_ratio=80;
#sysctl -w vm.vfs_cache_pressure=10;
#sysctl -w vm.overcommit_memory=1;
#sysctl -w vm.oom_kill_allocating_task=0;


# =========
# TWEAKS: adding zram swap in RAM
# =========

#insmod /system/modules/zram.ko num_devices=1
#echo $((96*1024*1024)) > /sys/block/zram0/disksize
#mknod /dev/zram0 b 253 0
#mkswap /dev/zram0
#swapon /dev/zram0
		
# ==============================================================
# ==============================================================
# ==============================================================
# renice processes at wake. Credits to lpy: http://forum.xda-developers.com/showthread.php?t=1137554
# ==============================================================
# ==============================================================
# ==============================================================


    ### Phone dialer app ###
#    renice -1 `pidof com.android.phone`;

    ### System apps ###
#    renice -1 `pidof com.android.mms`; # Text message app
#    renice -1 `pidof com.swype.android.inputmethod`; # Keyboard
#    renice -1 `pidof com.sec.android.app.controlpanel`; # Task manager
#    renice -1 `pidof com.android.systemui`; # Status bar
#    renice -1 `pidof com.android.settings`; # Settings menu
#    renice -1 `pidof com.android.vending`; # Market app
#    renice -1 `pidof com.sec.android.app.camera`; # Camera app
#    renice -1 `pidof android.process.acore`;
#    renice -1 `pidof kondemand/0`;
#    renice -1 `pidof ksmartass_up/0`;
  


# ==============================================================
# ==============================================================
# ==============================================================
# network speed and throughput
# ==============================================================
# ==============================================================
# ==============================================================



# =========
# TWEAKS: for TCP read/write
# =========

sysctl -w net.ipv4.tcp_timestamps=0;
sysctl -w net.ipv4.tcp_tw_reuse=1;
sysctl -w net.ipv4.tcp_sack=1;
sysctl -w net.ipv4.tcp_dsack=1;
sysctl -w net.ipv4.tcp_tw_recycle=1;
sysctl -w net.ipv4.tcp_window_scaling=1;
sysctl -w net.ipv4.tcp_keepalive_probes=5;
sysctl -w net.ipv4.tcp_keepalive_intvl=30;
sysctl -w net.ipv4.tcp_fin_timeout=30;
sysctl -w net.ipv4.tcp_moderate_rcvbuf=1;


# Commented out - Use the kernel defaults instead

#echo 524288 > /proc/sys/net/core/wmem_max;
#echo 524288 > /proc/sys/net/core/rmem_max;

# Commented out - Use the kernel defaults instead
# increase Linux auto tuning TCP buffer limits
# min, default, and max number of bytes to use
# set max to at least 4MB, or higher if you use very high BDP paths
#echo "524280" > /proc/sys/net/core/rmem_default # default: 
#echo "524280" > /proc/sys/net/core/wmem_default # default: 

# Commented out - Use the kernel defaults instead
# Increase the maximum total TCP buffer-space allocatable
#sysctl -w net.ipv4.tcp_mem="57344 57344 524288";

# Commented out - Use the kernel defaults instead
#echo 256960 > /proc/sys/net/core/rmem_default;
#echo 256960 > /proc/sys/net/core/wmem_default;
#echo 4096 16384 404480 > /proc/sys/net/ipv4/tcp_wmem;
#echo 4096 87380 404480 > /proc/sys/net/ipv4/tcp_rmem;

# Commented out - Use the kernel defaults instead
# Increase the tcp-time-wait buckets pool size
#sysctl -w net.ipv4.tcp_max_tw_buckets="1440000"
# default: 180000

# Commented out - Use the kernel defaults instead
# Increase the maximum amount of option memory buffers
#sysctl -w net.core.optmem_max="57344"
# default: 20480

# Commented out - Use the kernel defaults instead
# disable ECN
# enable it - since it's needed for SFB to work properly/optimally
# echo "0" > /proc/sys/net/ipv4/tcp_ecn # default at 2
# explicitly disable it since there's still buggy routers and other stations involved that break networking



# ==============================================================
# ==============================================================
# ==============================================================
# network security related settings
# ==============================================================
# ==============================================================
# ==============================================================



# Commented out - Use the kernel defaults instead
# disables IP source routing (for ipv4)

#for i in /proc/sys/net/ipv4/conf/*; do
#         /bin/echo "0" >  $i/accept_source_route
#done # does not get applied - FIXME

## echo "1" > /proc/sys/net/ipv4/conf/all/accept_source_route ## fix wifi, networking issues # leave at default

# Commented out - Use the kernel defaults instead
#for i in /proc/sys/net/ipv6/conf/*; do
#         /bin/echo "0" >  $i/accept_source_route
#done # does not get applied - FIXME

# Commented out - Use the kernel defaults instead
## echo "1" > /proc/sys/net/ipv6/conf/all/accept_source_route ## fix wifi, networking issues # leave at default

# These commands configure the server to ignore redirects from machines that are listed as
# gateways. Redirect can be used to perform attacks, so we only want to allow them from
# trusted sources:

# Commented out - Use the kernel defaults instead
#for i in /proc/sys/net/ipv4/conf/*; do
#         /bin/echo "1" >  $i/secure_redirects
#done

## echo "0" > /proc/sys/net/ipv4/conf/all/secure_redirects ## fix wifi, networking issues # leave at default

#for i in /proc/sys/net/ipv6/conf/*; do
#         /bin/echo "1" >  $i/secure_redirects
#done

# Commented out - Use the kernel defaults instead
# disables IP redirects (for ipv4)
#for i in /proc/sys/net/ipv4/conf/*; do
#         /bin/echo "0" >  $i/accept_redirects
#done # does not get applied - FIXME

# echo "1" > /proc/sys/net/ipv4/conf/all/accept_redirects ## fix wifi, networking issues # leave at default

#for i in /proc/sys/net/ipv6/conf/*; do
#         /bin/echo "0" >  $i/accept_redirects
#done # does not get applied - FIXME

# echo "1" > /proc/sys/net/ipv6/conf/all/accept_redirects ## fix wifi, networking issues # leave at default

# If this server does not act as a router, it does not have to send redirects, so they can be
# disabled:

#for i in /proc/sys/net/ipv4/conf/*; do
#         /bin/echo "0" >  $i/send_redirects
#done # does not get applied - FIXME

# Commented out - Use the kernel defaults instead
# echo "1" > /proc/sys/net/ipv4/conf/all/send_redirects ## fix wifi, networking issues # # leave at default

# Configure the server to ignore broadcast pings and smurf attacks:
# (smurf-attacks)
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1;
if [ -e /proc/sys/net/ipv6/icmp_echo_ignore_broadcasts ]
then
	echo "1" >  /proc/sys/net/ipv6/icmp_echo_ignore_broadcasts; # default
fi;

# Ignore all kinds of icmp packets or pings:
sysctl -w net.ipv4.icmp_echo_ignore_all=1;
if [ -e /proc/sys/net/ipv6/icmp_echo_ignore_all ]
then
	echo "1" >  /proc/sys/net/ipv6/icmp_echo_ignore_all; # default: 0
fi;
# Some routers send invalid responses to broadcast frames, and each one generates a
# warning that is logged by the kernel. These responses can be ignored:
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1;
if [ -e /proc/sys/net/ipv6/icmp_ignore_bogus_error_responses ]
then
	echo "1" >  /proc/sys/net/ipv6/icmp_ignore_bogus_error_responses;
fi;
# When the server is heavily loaded or has many clients with bad connections with high
# latency, it can result in an increase in half-open connections. This is common for Web
# servers, especially when there are a lot of dial-up users. These half-open connections are
# stored in the backlog connections queue. You should set this value to at least 4096. (The
# default is 1024.)
# Setting this value is useful even if your server does not receive this kind of connection,
# because it can still be protected from a DoS (syn-flood) attack.
sysctl -w net.ipv4.tcp_max_syn_backlog=4096; # default: 128

# Commented out - Use the kernel defaults instead
#echo 2 > /proc/sys/net/ipv4/tcp_synack_retries; # default: 5

# Increase the number of outstanding syn requests allowed.
# Note: some people (including myself) have used tcp_syncookies to handle the problem of too many legitimate outstanding SYNs. 
sysctl -w net.core.netdev_max_backlog=2500;

# While TCP SYN cookies are helpful in protecting the server from syn-flood attacks, both
# denial-of-service (DoS) or distributed denial-of-service (DDoS), they could have an
# adverse effect on performance. We suggest enabling TCP SYN cookies only when there is
# a clear need for them.

# disabling syncookies
sysctl -w net.ipv4.tcp_syncookies=0;

# Commented out - Use the kernel defaults instead
# We have also learned that window scaling can be an option to enlarge the transfer
# window. However, benchmarks have shown that window scaling is not suited for systems
# experiencing very high network load. Additionally, some network devices do not follow the
# RFC guidelines and could cause window scaling to malfunction. We suggest disabling
# window scaling and manually setting the window sizes.

# log and drop "martian" packets

#for i in /proc/sys/net/ipv4/conf/*; do
#         /bin/echo "1" >  $i/log_martians
#done # does not get applied - FIXME

# echo "1" > /proc/sys/net/ipv4/conf/all/log_martians

# Commented out - Use the kernel defaults instead
# enable reverse path-filtering  [prevents IP-Spoofing]
#for i in /proc/sys/net/ipv4/conf/*; do
#         /bin/echo "1" >  $i/rp_filter
#done # does not get applied - FIXME

#echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter # not enabled by default # uncomment for enhanced security & NOT using VPN (breaks VPN functionality)

# disable  IP dynaddr
sysctl -w net.ipv4.ip_dynaddr=0;




# ==============================================================
# ==============================================================
# ==============================================================
# general phone/RIL-related settings
# ==============================================================
# ==============================================================
# ==============================================================

# Seems to give undesired effect on certain phones. Commenting out.
# For HSDPA low throughput
# setprop ro.ril.disable.power.collapse = 1

# =========
# TWEAKS: overall
# =========
#setprop ro.telephony.call_ring.delay 1000; # let's minimize the time Android waits until it rings on a call
#setprop dalvik.vm.startheapsize 8m;
#if [ "`getprop dalvik.vm.heapsize | sed 's/m//g'`" -lt 64 ];then
#	setprop dalvik.vm.heapsize 64m; # leave that setting to cyanogenmod settings or uncomment it if needed
#fi;
#setprop wifi.supplicant_scan_interval 120; # higher is not recommended, scans while not connected anyway so shouldn't affect while connected
#if  [ -z "`getprop windowsmgr.max_events_per_sec`"  ] || [ "`getprop windowsmgr.max_events_per_sec`" -lt 60 ];then
#	setprop windowsmgr.max_events_per_sec 60; # smoother GUI
#fi;

#sysctl -w kernel.sem="500 512000 100 2048";
#sysctl -w kernel.shmmax=268435456;
#sysctl -w kernel.msgmni=1024;

