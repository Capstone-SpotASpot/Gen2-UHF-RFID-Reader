#!/usr/bin/env bash
# -*- coding: utf-8 -*-

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root ('sudo')"
    exit
fi

# Resets neccessary environment to detect tags
START_DIR="${PWD}"
JETSON_SETTINGS="${HOME}/jetson.conf"

echo "Setting TX2 Runtime Environment"
# get starting network params
STARTING_RMEM=229376 # $(sysctl -n net.core.rmem_max)
STARTING_WMEM=229376 # $(sysctl -n net.core.wmem_max)

# reset env
echo "Resetting TX2 Environment"
sysctl -w net.core.rmem_max=${STARTING_RMEM}
sysctl -w net.core.wmem_max=${STARTING_WMEM}
su -c "echo 0 > /sys/devices/system/cpu/cpu1/online"
su -c "echo 0 > /sys/devices/system/cpu/cpu2/online"
/home/nvidia/jetson_clocks.sh --restore "${JETSON_SETTINGS}"
