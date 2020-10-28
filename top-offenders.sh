#!/bin/bash

top -b -n 1 | grep qemu | awk '{print$1}' >> /tmp/top-offending-pids.$(date +%F).txt


for i in $(cat /tmp/top-offending-pids.$(date +%F).txt); do  ps aux | grep $i | grep -oP '(?<=uuid ).+?(?=-smbios)' >>  /tmp/libvirt-uuids_$(date +%F).txt ;done

head -5 /tmp/libvirt-uuids_$(date +%F).txt

echo "================================="
echo "see /tmp/libvirt-uuids_$(date +%F).txt for full list of uuids"
echo "================================="
