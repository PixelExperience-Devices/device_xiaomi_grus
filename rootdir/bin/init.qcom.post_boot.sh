#!/vendor/bin/sh

kwrite(){
  echo $1 2>&1 >/dev/kmsg;
}

write(){
  echo $2 > $1
    [[ "$?" == "1" ]] && { kwrite "okita: failed to set $1 to $2"; }
}

function configure_zram_parameters() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    low_ram=`getprop ro.config.low_ram`

    # Zram disk - 75% for Go devices.
    # For 512MB Go device, size = 384MB, set same for Non-Go.
    # For 1GB Go device, size = 768MB, set same for Non-Go.
    # For >=2GB Non-Go device, size = 1GB
    # And enable lz4 zram compression for Go targets.

    if [ "$low_ram" == "true" ]; then 
        echo lz4 > /sys/block/zram0/comp_algorithm
    fi   

    if [ -f /sys/block/zram0/disksize ]; then 
        if [ $MemTotal -le 524288 ]; then 
            echo 402653184 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 1048576 ]; then 
            echo 805306368 > /sys/block/zram0/disksize
        else 
            # Set Zram disk size=1.5GB for >=2GB Non-Go targets.
            echo 1585446912 > /sys/block/zram0/disksize
        fi   
        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi   
}

configure_zram_parameters

# Core control parameters on silver
echo 0 0 0 0 1 1 > /sys/devices/system/cpu/cpu0/core_ctl/not_preferred
echo 2 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
echo 40 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster
echo 8 > /sys/devices/system/cpu/cpu0/core_ctl/task_thres

# Setting b.L scheduler parameters
echo 96 > /proc/sys/kernel/sched_upmigrate
echo 90 > /proc/sys/kernel/sched_downmigrate
echo 140 > /proc/sys/kernel/sched_group_upmigrate
echo 120 > /proc/sys/kernel/sched_group_downmigrate
echo 1 > /proc/sys/kernel/sched_walt_rotate_big_tasks

# configure governor settings for little cluster
#echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/rate_limit_us
#echo 1209600 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
#echo 576000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
# configure governor settings for big cluster
#echo "schedutil" > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
#echo 0 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/rate_limit_us
#echo 1344000 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_freq
#echo 652800 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

# sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
echo -6 >  /sys/devices/system/cpu/cpu6/sched_load_boost
echo -6 >  /sys/devices/system/cpu/cpu7/sched_load_boost
echo 85 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_load

echo "0:1209600" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms

# Set Memory parameters
# configure_memory_parameters

# Enable bus-dcvs
for cpubw in /sys/class/devfreq/*qcom,cpubw*
do
    echo "bw_hwmon" > $cpubw/governor
    echo 50 > $cpubw/polling_interval
    echo "1144 1720 2086 2929 3879 5931 6881" > $cpubw/bw_hwmon/mbps_zones
    echo 4 > $cpubw/bw_hwmon/sample_ms
    echo 68 > $cpubw/bw_hwmon/io_percent
    echo 20 > $cpubw/bw_hwmon/hist_memory
    echo 0 > $cpubw/bw_hwmon/hyst_length
    echo 80 > $cpubw/bw_hwmon/down_thres
    echo 0 > $cpubw/bw_hwmon/guard_band_mbps
    echo 250 > $cpubw/bw_hwmon/up_scale
    echo 1600 > $cpubw/bw_hwmon/idle_mbps
done

#Enable mem_latency governor for DDR scaling
for memlat in /sys/class/devfreq/*qcom,memlat-cpu*
do
    echo "mem_latency" > $memlat/governor
    echo 10 > $memlat/polling_interval
    echo 400 > $memlat/mem_latency/ratio_ceil
done

#Enable mem_latency governor for L3 scaling
for memlat in /sys/class/devfreq/*qcom,l3-cpu*
do
    echo "mem_latency" > $memlat/governor
    echo 10 > $memlat/polling_interval
    echo 400 > $memlat/mem_latency/ratio_ceil
done

#Enable userspace governor for L3 cdsp nodes
for l3cdsp in /sys/class/devfreq/*qcom,l3-cdsp*
do
    echo "userspace" > $l3cdsp/governor
    chown -h system $l3cdsp/userspace/set_freq
done

echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor

# Disable CPU Retention
echo N > /sys/module/lpm_levels/L3/cpu0/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu1/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu2/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu3/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu4/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu5/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu6/ret/idle_enabled
echo N > /sys/module/lpm_levels/L3/cpu7/ret/idle_enabled

# cpuset parameters
#echo 0-5 > /dev/cpuset/background/cpus
#echo 0-5 > /dev/cpuset/system-background/cpus
echo 0-1 > /dev/cpuset/background/cpus
echo 0-2 > /dev/cpuset/system-background/cpus
echo 0-3 > /dev/cpuset/restricted/cpus

# Turn off scheduler boost at the end
echo 0 > /proc/sys/kernel/sched_boost

# Turn on sleep modes.
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled


cpuA=/sys/devices/system/cpu/cpufreq/policy0
cpuB=/sys/devices/system/cpu/cpufreq/policy6

write $cpuA/scaling_min_freq 576000
write $cpuA/scaling_governor schedutil
write $cpuA/schedutil/iowait_boost_enable 0
write $cpuA/schedutil/pl 0
write $cpuA/schedutil/up_rate_limit_us 20000
write $cpuA/schedutil/down_rate_limit_us 500

write $cpuB/scaling_min_freq 652000
write $cpuB/scaling_governor schedutil
write $cpuB/schedutil/iowait_boost_enable 0
write $cpuB/schedutil/pl 0
write $cpuB/schedutil/up_rate_limit_us 20000
write $cpuB/schedutil/down_rate_limit_us 500

# Enable idle state listener
write /sys/class/drm/card0/device/idle_encoder_mask 1
write /sys/class/drm/card0/device/idle_timeout_ms 64

# Setup Memory Management
write /proc/sys/vm/dirty_ratio 80
write /proc/sys/vm/dirty_expire_centisecs 3000
write /proc/sys/vm/dirty_background_ratio 8
write /proc/sys/vm/page-cluster 0

# Reset default thermal config
chmod 644 /sys/class/thermal/thermal_message/sconfig
write /sys/class/thermal/thermal_message/sconfig 16
chmod 444 /sys/class/thermal/thermal_message/sconfig

# Unify all blocks setup
for i in /sys/block/*/queue; do
  write $i/read_ahead_kb 256
  write $i/add_random 0
  write $i/iostats 0
  write $i/rotational 0
  write $i/scheduler bfq
done

# Reset entropy values
write /proc/sys/kernel/random/read_wakeup_threshold 128
write /proc/sys/kernel/random/write_wakeup_threshold 128

echo 100 > /proc/sys/vm/swappiness

adj_series=`cat /sys/module/lowmemorykiller/parameters/adj`
adj_1="${adj_series#*,}"
set_almk_ppr_adj="${adj_1%%,*}"
set_almk_ppr_adj=$(((set_almk_ppr_adj * 6) + 6))
echo $set_almk_ppr_adj > /sys/module/lowmemorykiller/parameters/adj_max_shift

minfree_series=`cat /sys/module/lowmemorykiller/parameters/minfree`
minfree_1="${minfree_series#*,}" ; rem_minfree_1="${minfree_1%%,*}"
minfree_2="${minfree_1#*,}" ; rem_minfree_2="${minfree_2%%,*}"
minfree_3="${minfree_2#*,}" ; rem_minfree_3="${minfree_3%%,*}"
minfree_4="${minfree_3#*,}" ; rem_minfree_4="${minfree_4%%,*}"
minfree_5="${minfree_4#*,}"

vmpres_file_min=$((minfree_5 + (minfree_5 - rem_minfree_4)))
echo $vmpres_file_min > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo "18432,23040,27648,32256,85296,120640" > /sys/module/lowmemorykiller/parameters/minfree

echo "15360,19200,23040,26880,34415,43737" > /sys/module/lowmemorykiller/parameters/minfree
echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk

# Enable oom_reaper
if [ -f /sys/module/lowmemorykiller/parameters/oom_reaper ]; then
    echo 1 > /sys/module/lowmemorykiller/parameters/oom_reaper
fi

#Set PPR parameters for all other targets.
#echo $set_almk_ppr_adj > /sys/module/process_reclaim/parameters/min_score_adj
#echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
#echo 50 > /sys/module/process_reclaim/parameters/pressure_min
#echo 70 > /sys/module/process_reclaim/parameters/pressure_max
#echo 30 > /sys/module/process_reclaim/parameters/swap_opt_eff
#echo 512 > /sys/module/process_reclaim/parameters/per_swap_size

# Let kernel know our image version/variant/crm_version
if [ -f /sys/devices/soc0/select_image ]; then
    image_version="10:"
    image_version+=`getprop ro.build.id`
    image_version+=":"
    image_version+=`getprop ro.build.version.incremental`
    image_variant=`getprop ro.product.name`
    image_variant+="-"
    image_variant+=`getprop ro.build.type`
    oem_version=`getprop ro.build.version.codename`
    echo 10 > /sys/devices/soc0/select_image
    echo $image_version > /sys/devices/soc0/image_version
    echo $image_variant > /sys/devices/soc0/image_variant
    echo $oem_version > /sys/devices/soc0/image_crm_version
fi

echo 0 > /proc/sys/kernel/printk

# Parse misc partition path and set property
misc_link=$(ls -l /dev/block/bootdevice/by-name/misc)
real_path=${misc_link##*>}
setprop persist.vendor.mmi.misc_dev_path $real_path
