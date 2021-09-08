#!/bin/zsh

TOTAL_WORKLOAD_SIZE_GB=256
FILE_SIZE_GB=1
export BLOCKSIZE=4kb
export RW=${2}
export ENGINE=${4}
export THREADS=${3}
export FDATASYNC=0
export DIRECT=1
export SYNC=1
export MOUNTPOINTSOCKET0=/mnt
SIZE_PER_JOB=`expr ${TOTAL_WORKLOAD_SIZE_GB} \/ $3`
export WORKLOAD_SIZE="${SIZE_PER_JOB}G"
export FILES=`expr ${SIZE_PER_JOB} \/ ${FILE_SIZE_GB}`


fio ${1} > result/${6}_${1%.*}_${RW}_${THREADS}_${5}_${4}.txt
