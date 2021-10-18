#!/bin/zsh

#RAIDS=("raid0hw" "raid0s" "raid0l")
#RAIDS=("raid0s01" "raid0s02" "raid0s03")
#RAIDS=("raid0s")
RAIDS=("raid0s128b" "raid0s256b")
WORKLOADS=("read" "write" "randread" "randwrite")
THREADS=("1" "2" "4" "8" "16")
#IOENGINES=("block_psync" "dax_psync")
#IOENGINES=("dax_libpmem")
IOENGINES=("dax_psync")

for raid in ${RAIDS[@]}; do
	echo "===============${raid}==============="
	for ioengine in ${IOENGINES[@]}; do
		echo "===============${ioengine}==============="
		for workload in ${WORKLOADS[@]}; do
			for thread in ${THREADS[@]}; do
				file_name="${raid}_exp_${workload}_${thread}_${ioengine}.txt"
#echo $file_name
				./parse.sh $file_name
			done
		done
	done
done
