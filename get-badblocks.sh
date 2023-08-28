#!/bin/bash
serial=$1
echo "Checking for badblocks for drive $serial"
if [[ -f $serial-badblocks ]]; then
        echo "Drive has been scanned, checking for blocks"
        blocks=$(wc -l $serial-badblocks | awk -F ' ' ' { print $1 } ')
        echo "$blocks found"
else
        echo "Badblock file not found. Drive not scanned?"
fi
