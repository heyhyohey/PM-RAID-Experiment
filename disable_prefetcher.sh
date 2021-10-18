#!/bin/zsh

modprobe msr
wrmsr -a 0x1a4 0xf
