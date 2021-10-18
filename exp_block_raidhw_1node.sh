#!/bin/zsh

WORKLOAD_LIST=("read" "write" "randread" "randwrite")
THREADS_LIST=("1" "2" "4" "8" "16")
IO_ENGINE="psync"
LV_DEVICE="raid0128"
DEVICE_PATH="/dev/pmem0"
MOUNT_PATH="/mnt"
CPU_NODES="0"

for workload in ${WORKLOAD_LIST[@]}; do
	for threads in ${THREADS_LIST[@]}; do
		mkfs.xfs -f -i size=2048 -d su=2m,sw=1 ${DEVICE_PATH}
		mount -t xfs -o noatime,nodiratime,nodiscard ${DEVICE_PATH} ${MOUNT_PATH}
		xfs_io -c "extsize 2m" /mnt
		numactl --cpunodebind=${CPU_NODES} ./fio.sh exp.fio ${workload} ${threads} ${IO_ENGINE} block ${LV_DEVICE}
		umount /mnt
		echo 3 > /proc/sys/vm/drop_caches
		sync
	done
done
