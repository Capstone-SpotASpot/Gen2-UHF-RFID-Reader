#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Sets up neccessary environment & runs reader.py to detect tags

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root ('sudo')"
    exit
fi

START_DIR="${PWD}"
THIS_FILE_DIR="$(readlink -fm $0/..)"

echo "Setting TX2 Runtime Environment"
bash "${THIS_FILE_DIR}/set_tx2_reader_env.sh"

# need to be in reader.py's directory to start
cd "${THIS_FILE_DIR}/gr-rfid/apps/"
sudo GR_SCHEDULER=STS nice -n -20 python2 ./reader.py -a .9 -t 20 -r 20 -f 910e6

# reset env
bash "${THIS_FILE_DIR}/unset_tx2_reader_env.sh"

cd "${START_DIR}"
