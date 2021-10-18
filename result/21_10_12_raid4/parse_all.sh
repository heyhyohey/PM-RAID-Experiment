#!/bin/zsh

#RAIDS=("raid0hw" "raid0s" "raid0l")
#RAIDS=("raid0s01" "raid0s02" "raid0s03")
RAIDS=("raid4")
WORKLOADS=("read" "write" "randread" "randwrite")
THREADS=("1" "2" "4" "8" "16" "32")
#IOENGINES=("dax_libpmem")
#IOENGINES=("dax_psync" "block_psync")
IOENGINES=("block_psync")
#FSYNCS=("1" "2" "10" "0")
FSYNCS=("1")

for raid in ${RAIDS[@]}; do
	echo "===============${raid}==============="
	for ioengine in ${IOENGINES[@]}; do
		echo "===============${ioengine}==============="
		for workload in ${WORKLOADS[@]}; do
			echo "===============${workload}==============="
			for thread in ${THREADS[@]}; do
#echo "===============${thread}==============="
				for fsync in ${FSYNCS[@]}; do
					file_name="${raid}_exp_${workload}_${thread}_${ioengine}_${fsync}.txt"
#echo $file_name
					./parse.sh $file_name
				done
			done
		done
	done
done
