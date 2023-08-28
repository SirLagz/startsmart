#!/bin/bash
drive=$1
echo $drive
blksize=$(lsblk -o phy-sec /dev/$drive | grep -vi phy-sec  | uniq | xargs)
serial=$(smartctl -i /dev/$drive | grep -i "serial number" | awk -F ' ' ' { print $3 } ')
echo Blocksize $blksize
echo Serial $serial
length=$(expr length $serial)
if [ ! -f $serial-smart ] && [ $length -gt 0 ]; then
    echo "smartctl -i /dev/$drive > $serial"
    smartctl -i /dev/$drive > $serial-smart
    echo "badblocks -b $blksize -c 65536 -swv /dev/$drive -o $serial-badblocks -p 2"
    screen -S $drive -L $serial-$drive-log -d -m /sbin/badblocks -b $blksize -c 65535 -wv /dev/$drive -o $serial-badblocks -p 2
else
    if [[ $length -eq 0 ]]; then
        echo "Serial number invalid, stopping"
    else
        echo "Drive scanned already. stopping"
        ./get-badblocks.sh $serial
    fi
fi
