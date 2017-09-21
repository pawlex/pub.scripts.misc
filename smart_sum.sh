#!/bin/bash

DISKS=`ls /dev/disk/by-id | grep "scsi-SATA" | grep -v "part"`
for DISK in $DISKS
do
 DEV=`readlink /dev/disk/by-id/$DISK | sed 's/..\///g'`
 echo "Printing non-zero SMART attributes for: $DISK ($DEV)"
 smartctl -T permissive -A /dev/disk/by-id/$DISK | awk '{ if($10) print }'
 echo ""
done
