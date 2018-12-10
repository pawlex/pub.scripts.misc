#!/bin/bash

SLAVES=$(ls /sys/block/md*/slaves | cut -c -3)

for n in $SLAVES; do
	TEMP=`smartctl -A /dev/$n | grep -i temp | awk '{ print $4 }'`
	echo $n: $TEMP
done
