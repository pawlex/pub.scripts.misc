#!/usr/bin/env bash
# Used to determine the optimal block size when using DD
#
# Paul Komurka : pawlex@gmail.com
#
#DDFLAGS="oflag=direct" # better for devices with a cache like rotational, SSD etc.
DDFLAGS="oflag=dsync"  # better for devices with no cache (USB, SSD etc)
DDBYTES="32M"
BLOCKSIZES=("512" "1K" "2K" "4K" "8K" "16K" "32K" "64K" "128K" "256K" "512K" "1M" "2M" "4M" "8M")
# don't touch
SRC=/dev/zero
TMP=/tmp/tmp.dd
NUL=/dev/null
DD=/bin/dd
RESULTS="/tmp/results.pk"

DDBYTES="iflag=count_bytes count=${DDBYTES}" 
DDFILTER="2>&1 | grep copied | cut -d , -f 4" # Grab only the final result
#TABLEIZE="column -t -c 3 -s \:"
TABLEIZE="column -t -c 2"


# See if we've passed an arg.
if [ -z "$1" ]; then
	DST=$TMP
else
	DST=$1
fi

echo "Baseline memory copy: "
rm ${RESULTS} 1>&2 2>/dev/null;
for b in ${BLOCKSIZES[@]}; do
	eval retval=\`${DD} if=${SRC} of=${NUL} bs=${b} ${DDBYTES} ${DDFILTER}\`
	eval \`echo ${b}: $retval ">>" ${RESULTS}\`
done
${TABLEIZE} ${RESULTS}
echo ""


#########################################
echo "Baseline filesystem copy to: ${TMP}"
echo "This will take a while.."
rm ${RESULTS} >/dev/null;
for b in ${BLOCKSIZES[@]}; do
	eval retval=\`${DD} if=${SRC} of=${TMP} bs=${b} ${DDFLAGS} ${DDBYTES} ${DDFILTER}\`
	eval \`echo ${b}: $retval ">>" ${RESULTS}\`
	#echo BLOCK SIZE: ${b}: $retval
done
${TABLEIZE} ${RESULTS}

echo "deleting temp file ${TMP} "
rm ${TMP}
echo ""

#########################################
# Nothing left to do.
if [ "${DST}" == ${TMP}  ]; then
	exit
fi
while true; do
    read -p "WARNING:  This will completely destroy ${DST}.  Proceed?? " yn
    case $yn in
        [Yy]* ) 
		echo ""
		echo "This will take a while.."
		rm ${RESULTS} >/dev/null;
		for b in ${BLOCKSIZES[@]}; do
			eval retval=\`${DD} if=${SRC} of=${DST} bs=${b} ${DDFLAGS} ${DDBYTES} ${DDFILTER}\`
			eval \`echo ${b}: $retval ">>" ${RESULTS}\`
			#echo BLOCK SIZE: ${b}: $retval
		done
	break;;
	[Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
${TABLEIZE} ${RESULTS}
rm ${RESULTS} >/dev/null;
echo ""

exit 0
