#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Must specify target filename"
	exit 0
fi

fio \
	--randrepeat=1 \
	--ioengine=libaio \
	--direct=1 \
	--gtod_reduce=1 \
	--name=test \
	--filename=$1 \
	--bs=4k \
	--iodepth=64 \
	--size=4G \
	--readwrite=randrw \
	--rwmixread=75 \
	--output=${1}.log
#
