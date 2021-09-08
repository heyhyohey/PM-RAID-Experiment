#!/bin/zsh

WORKLOAD_LIST=("read" "write" "randread" "randwrite")
THREADS_LIST=("1" "2" "4" "8" "16")
DEVICE_LIST=("/dev/pmem0" "/dev/pmem1" "/dev/pmem2" "/dev/pmem3" "/dev/pmem4" "/dev/pmem5")
DEVICE_PATH="/dev/PmemVol/raid0s"
MOUNT_PATH="/mnt"
IO_ENGINE="libpmem"
LV_DEVICE="raid0l"
INTERLEAVE_COUNT=${#DEVICE_LIST[@]}

echo ${INTERLEAVE_COUNT}

for workload in ${WORKLOAD_LIST[@]}; do
	for threads in ${THREADS_LIST[@]}; do
		DEVICES=""
		for device in ${DEVICE_LIST[@]}; do
			pvcreate -M2 --dataalignment 2m ${device}
			DEVICES="${DEVICES} ${device}"
		done
		vgcreate --physicalextentsize 2m PmemVol ${DEVICES}
		lvcreate -l 100%FREE -n ${LV_DEVICE} PmemVol
		mkfs.xfs -f -i size=2048 -d su=2m,sw=${INTERLEAVE_COUNT} -m reflink=0 ${DEVICE_PATH}
		mount -t xfs -o noatime,nodiratime,nodiscard,dax ${DEVICE_PATH} ${MOUNT_PATH}
		xfs_io -c "extsize 2m" /mnt
		./fio.sh exp.fio ${workload} ${threads} ${IO_ENGINE} dax ${LV_DEVICE}
		umount /mnt
		lvremove -y /dev/PmemVol/raid0s
		vgremove -y PmemVol
		pvremove -y /dev/pmem*
		echo 3 > /proc/sys/vm/drop_caches
		sync
	done
done
