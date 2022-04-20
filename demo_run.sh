#!/usr/bin/env bash

while true
do
    (sleep 16 && echo 'q') | bash ./run_tx2_reader.sh
done
