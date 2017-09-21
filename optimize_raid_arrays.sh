#!/bin/bash

NORMALDISKS=`ls /sys/block/ | egrep "(^sd|^hd)"`
RAIDDISKS=`ls /sys/block/ | egrep "(^md)"`
BLOCKDEV='/sbin/blockdev'
#SCSIZE=16384
SCSIZE=8192
#REBUILD_RATE=28000
#REBUILD_RATE=20000
REBUILD_RATE=20000

MD_RAVAL=2048
MD_NCQVAL=1
DEFAULT_SCHEDULER="deadline"
MD_SCHEDULER="deadline"
#MD_SCHEDULER="noop"
MD_DEVICES=`ls /sys/block/ | egrep "(^md)"`
MD_MEMBERS=`find /sys/devices/virtual/block/md*/slaves -type l | cut -d "/" -f 8 | cut -c 1-3`
ALL_DEVICES=`find /sys/devices -name scheduler`

# blanket set scheduler
for DEV in $ALL_DEVICES
do
	echo $DEFAULT_SCHEDULER > $DEV
done

for DEV in $MD_MEMBERS
do
 echo "[$DEV]: scheduler: $MD_SCHEDULER"
 #cat /sys/block/$DEV/queue/scheduler
 echo $MD_SCHEDULER > /sys/block/$DEV/queue/scheduler
 echo "[$DEV]: queue depth: $MD_NCQVAL"
 #cat /sys/block/$DEV/device/queue_depth
 echo $MD_NCQVAL > /sys/block/$DEV/device/queue_depth
done

for i in $RAIDDISKS
do
 echo "Setting MD-block device $i read-ahead value to $MD_RAVAL and stripe-cache to $SCSIZE"
 #${BLOCKDEV} --getra /dev/$i
 ${BLOCKDEV} --setra $MD_RAVAL /dev/$i
 #cat /sys/block/$i/md/stripe_cache_size
 echo $SCSIZE > /sys/block/$i/md/stripe_cache_size
done

#sysctl dev.raid.speed_limit_min
#sysctl dev.raid.speed_limit_max
sysctl -w dev.raid.speed_limit_min=$REBUILD_RATE
sysctl -w dev.raid.speed_limit_max=$REBUILD_RATE
