#!/bin/zsh

FILE_NAME=$1
THROUGHPUT_UNITS=`cat $FILE_NAME | grep "bw (" | cut -f 1 -d ':' | sed "s/\ //g"`
LATENCY_UNITS=`cat $FILE_NAME | grep "lat (" | sed -n "2p" | cut -f 1 -d ':' | sed "s/\ //g"`

# latency
latency=`cat $FILE_NAME | grep "lat (" | sed -n "2p" | awk -F ',' '{ print $3 }' | cut -f 2 -d '='`
if [ "$LATENCY_UNITS" = "lat(usec)" ]; then
	latency=`echo "scale=2;${latency} * 1000.0" | bc`
fi
echo -n "${latency},"

# bw
throughput=`cat $FILE_NAME | grep "bw (" | awk -F ',' '{ print $4 }' | cut -f 2 -d '='`

if [ "$THROUGHPUT_UNITS" = "bw(KiB/s)" ]; then
	throughput=`echo "scale=2;${throughput} / 1000.0" | bc`
fi
echo -n "${throughput},"

# iops
cat $FILE_NAME | grep "iops" | awk -F ',' '{ print $3 }' | cut -f 2 -d '='
