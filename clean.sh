#!/bin/zsh

vgremove PmemVol &&
pvremove /dev/pmem*
