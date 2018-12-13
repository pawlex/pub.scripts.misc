#!/bin/bash

BLOCKDEV='/sbin/blockdev'
SYSCTL='/sbin/sysctl'

# MD array stripe cache size
# memory_consumed = system_page_size * nr_disks * stripe_cache_size
# 4k pages * 4 disks * 16384 = 256MB
SC_SIZE=16384

# MD Rebuild rate 50,000 = 50MB/s.
REBUILD_RATE=50000
REBUILD_RATE_MIN=`expr $REBUILD_RATE / 10`

# MD device Read-ahead value (in 512-byte blocks)
MD_RAVAL=16384

# MD member read-ahead value (in 512-byte blocks)
MEMBER_RAVAL=8192 # 4MB

# MD Member NCQ depth.  
# Higher value = higher latency and higher throughput
MEMBER_NCQVAL=31

# Default schedulres
DEFAULT_SCHEDULER="noop"
MEMBER_SCHEDULER="noop"
MD_SCHEDULER="cfq"

####
MD_DEVICES=`ls /sys/block/ | egrep "(^md)"`
MD_MEMBERS=`find /sys/devices/virtual/block/md*/slaves -type l | cut -d "/" -f 8 | cut -c 1-3`
ALL_DEVICES=`find /sys/devices -name scheduler`
####

# blanket set scheduler
echo "[ALL]: Setting default scheduler to $DEFAULT_SCHEDULER"
for SYSPATH in $ALL_DEVICES
do
    echo $DEFAULT_SCHEDULER > $SYSPATH 2>&1 > /dev/null
done

for DEV in $MD_MEMBERS
do
    echo "[$DEV]: scheduler: $MEMBER_SCHEDULER"
    echo $MEMBER_SCHEDULER > /sys/block/$DEV/queue/scheduler
    #
    echo "[$DEV]: queue depth: $MEMBER_NCQVAL"
    echo $MEMBER_NCQVAL > /sys/block/$DEV/device/queue_depth
    #
    echo "[$DEV]: read-ahead: $MEMBER_RAVAL"
    ${BLOCKDEV} --setra $MEMBER_RAVAL /dev/$DEV
done

for DEV in $MD_DEVICES
do
    echo "[$DEV]: scheduler: $MD_SCHEDULER"
    echo $MD_SCHEDULER > /sys/block/$DEV/queue/scheduler
    #
    echo "[$DEV]: read-ahead: $MD_RAVAL"
    ${BLOCKDEV} --setra $MD_RAVAL /dev/$DEV
    #
    if [ -f /sys/block/$DEV/md/stripe_cache_size ]; then
        echo "[$DEV]: stripe-cache: $SC_SIZE"
        echo $SC_SIZE > /sys/block/$DEV/md/stripe_cache_size
    fi
done

${SYSCTL} -w dev.raid.speed_limit_min=$REBUILD_RATE_MIN
${SYSCTL} -w dev.raid.speed_limit_max=$REBUILD_RATE

exit 0
