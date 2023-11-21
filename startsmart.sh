#!/bin/bash
if [[ $(which smartctl) ]]; then
drive=$1
echo $drive
blksize=$(lsblk -o phy-sec /dev/$drive | grep -vi phy-sec  | uniq | xargs)
serial=$(smartctl -i /dev/$drive | grep -i "serial number" | awk -F ' ' ' { print $3 } ')
echo Blocksize $blksize
echo Serial $serial
length=$(expr length $serial)
if [ ! -f $serial-smart ] && [ $length -gt 0 ]; then
    echo "smartctl -i /dev/$drive > $serial-smart"
    smartctl -i /dev/$drive > $serial-smart
    if [[ $(smartctl -A /dev/$drive | grep -E '^\s+5|^187|^188|^189|^197|^198' | awk -F ' ' ' { print $10 } ' | grep -v 0 | wc -l) -gt 0 ]]; then 
        echo 'SMART attributes failed. Please check below output.'
        smartctl -A /dev/$drive | grep -E '^\s+5|^187|^188|^189|^197|^198' | awk -F ' ' ' { print $1 " - " $2 " - " $10 } '
    else
        echo 'SMART attributes passed'
    fi

    echo "/sbin/badblocks -b $blksize -c 65536 -wv /dev/$drive -o $serial-badblocks"
    screen -S $drive -L -Logfile $serial-$drive-log -d -m /sbin/badblocks -b $blksize -c 65535 -wv /dev/$drive -o $serial-badblocks
else
    if [[ $length -eq 0 ]]; then
        echo "Serial number invalid, stopping"
    else
        echo "Drive scanned already. stopping"
        if [[ $(smartctl -A /dev/$drive | grep -E '^\s+5|^187|^188|^189|^197|^198' | awk -F ' ' ' { print $10 } ' | grep -v 0 | wc -l) -gt 0 ]]; then 
            echo 'SMART attributes failed. Please check below output.'
            smartctl -A /dev/$drive | grep -E '^\s+5|^187|^188|^189|^197|^198' | awk -F ' ' ' { print $1 " - " $2 " - " $10 } '
        else
            echo 'SMART attributes passed'
        fi
	./get-badblocks.sh $serial
    fi
fi
else
echo "smartctl not found. Aborting"
fi
