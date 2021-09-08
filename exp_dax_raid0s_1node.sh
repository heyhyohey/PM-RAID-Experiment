#!/bin/zsh

WORKLOAD_LIST=("read" "write" "randread" "randwrite")
THREADS_LIST=("1" "2" "4" "8" "16" "32")
DEVICE_LIST=("/dev/pmem0" "/dev/pmem1" "/dev/pmem2" "/dev/pmem3" "/dev/pmem4" "/dev/pmem5")
IO_ENGINE="psync"
LV_DEVICE="raid0s"
DEVICE_PATH="/dev/PmemVol/${LV_DEVICE}"
MOUNT_PATH="/mnt"
INTERLEAVE_COUNT=${#DEVICE_LIST[@]}

for workload in ${WORKLOAD_LIST[@]}; do
	for threads in ${THREADS_LIST[@]}; do
		DEVICES=""
		for device in ${DEVICE_LIST[@]}; do
			pvcreate -y -M2 --dataalignment 2m ${device}
		done
		vgcreate -y --physicalextentsize 2m PmemVol /dev/pmem*
		lvcreate -y -l 100%FREE -i ${INTERLEAVE_COUNT} -I 2m -C y -n ${LV_DEVICE} PmemVol
		mkfs.xfs -f -i size=2048 -d su=2m,sw=${INTERLEAVE_COUNT} -m reflink=0 ${DEVICE_PATH}
		mount -t xfs -o noatime,nodiratime,nodiscard,dax ${DEVICE_PATH} ${MOUNT_PATH}
		xfs_io -c "extsize 2m" /mnt
		./fio.sh exp.fio ${workload} ${threads} ${IO_ENGINE} dax ${LV_DEVICE}
		umount /mnt
		lvremove -y /dev/PmemVol/${LV_DEVICE}
		vgremove -y PmemVol
		pvremove -y /dev/pmem*
		echo 3 > /proc/sys/vm/drop_caches
		sync
	done
done
