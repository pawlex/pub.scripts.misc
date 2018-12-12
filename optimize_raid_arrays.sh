#!/bin/bash

# Stripe cache size.
SCSIZE=16384
# MD Rebuild rate 50,000 = 50MB/s.
REBUILD_RATE=50000
REBUILD_RATE_MIN=`expr $REBUILD_RATE / 10`
# MD device Read-ahead value
MD_RAVAL=16384
# MD member read-ahead value ( /512-byte )
MDMEMBER_RAVAL=8192 # 4MB
# MD Member NCQ depth.  Higher value = higher latency.
MD_NCQVAL=31
# Default schedulres
DEFAULT_SCHEDULER="noop"
MD_SCHEDULER="noop"



####
NORMALDISKS=`ls /sys/block/ | egrep "(^sd|^hd)"`
MD_DEVICES=`ls /sys/block/ | egrep "(^md)"`
BLOCKDEV='/sbin/blockdev'
MD_DEVICES=`ls /sys/block/ | egrep "(^md)"`
MD_MEMBERS=`find /sys/devices/virtual/block/md*/slaves -type l | cut -d "/" -f 8 | cut -c 1-3`
ALL_DEVICES=`find /sys/devices -name scheduler`
####


# blanket set scheduler
for DEV in $ALL_DEVICES
do
 echo $DEFAULT_SCHEDULER > $DEV 2>&1 > /dev/null
done

for DEV in $MD_MEMBERS
do
 echo "[$DEV]: scheduler: $MD_SCHEDULER"
 #cat /sys/block/$DEV/queue/scheduler
 echo $MD_SCHEDULER > /sys/block/$DEV/queue/scheduler
 echo "[$DEV]: queue depth: $MD_NCQVAL"
 #cat /sys/block/$DEV/device/queue_depth
 echo $MD_NCQVAL > /sys/block/$DEV/device/queue_depth
 echo "[$DEV]: read-ahead: $MDMEMBER_RAVAL"
 ${BLOCKDEV} --setra $MDMEMBER_RAVAL /dev/$DEV
done

for DEV in $MD_DEVICES
do
 # Read-ahead value
 echo "[$DEV]: read-ahead: $MD_RAVAL"
 ${BLOCKDEV} --setra $MD_RAVAL /dev/$DEV
 # Stripe cache
 if [ -f /sys/block/$DEV/md/stripe_cache_size ]; then
  echo "[$DEV]: stripe-cache: $SCSIZE"
  echo $SCSIZE > /sys/block/$DEV/md/stripe_cache_size
 fi

done

#sysctl dev.raid.speed_limit_min
#sysctl dev.raid.speed_limit_max
sysctl -w dev.raid.speed_limit_min=$REBUILD_RATE_MIN
sysctl -w dev.raid.speed_limit_max=$REBUILD_RATE
