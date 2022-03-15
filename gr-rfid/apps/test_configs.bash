#!/bin/bash

run_reader='sudo GR_SCHEDULER=STS nice -n -20 python2 ./reader.py'

function run_test () {
    # args: apml, tx_gain, rx_gain, freq
    (sleep 5 && echo "q") | ${run_reader} -a $1 -t $2 -r $3 -f $4 -o "${1}_${2}_${3}_${4}.data"
}

RX_GAIN="20"

for AMPL in {1..9} ; do
    for TX_GAIN in 1 2 4 8 16 ; do
        for FREQ in 890 900 910 ; do
            run_test 0.${AMPL} $TX_GAIN $RX_GAIN ${FREQ}e6
        done
    done
done

