#!/bin/bash

threshold=95
result=`df -BG --output=source,used,avail,pcent /dev/sda1 | grep -v "Filesystem" | awk '{ print $4}' | sed 's/%//g'`

if [ "$result" -gt  "$threshold" ]; then
	echo "disk usage ${result}% > ${threshold}%"
else
	echo "disk usage ${result}% <  ${threshold}%"
fi
