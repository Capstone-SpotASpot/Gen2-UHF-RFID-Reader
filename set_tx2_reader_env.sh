#!/usr/bin/env bash
# -*- coding: utf-8 -*-

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root ('sudo')"
    exit
fi

# Sets up neccessary environment to detect tags
START_DIR="${PWD}"
JETSON_SETTINGS="${HOME}/jetson.conf"

echo "Setting Runtime Environment"
# set network params
sysctl -w net.core.rmem_max=24266666
sysctl -w net.core.wmem_max=24266666

# make sure this is a tx2
if [ -f /home/nvidia/jetson_clocks.sh ]; then
    # turn max cpu performance on
    echo "See cpu info with /home/nvidia/tegrastats"
    su -c "echo 1 > /sys/devices/system/cpu/cpu1/online"
    su -c "echo 1 > /sys/devices/system/cpu/cpu2/online"
    rm -rf "${JETSON_SETTINGS}" # remove settings so dont ask if okay to overwrite
    /home/nvidia/jetson_clocks.sh --store "${JETSON_SETTINGS}" # save settings to restore from
    /home/nvidia/jetson_clocks.sh
fi
