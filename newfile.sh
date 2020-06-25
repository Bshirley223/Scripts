i#!/bin/bash



sudo salt '*cmp*' test.ping -t 7| grep cmp | sed 's/.$//'


CMP=`sudo salt '*cmp*1*' test.ping -t 7| grep cmp | sed 's/.$//'`

echo $CMP





read -p "Are you sure?"  -r
if [[ $REPLY =~ ^[Yy]$ ]]
 then
ssh $CMP  'ps aux | grep qemu | sort -k 3 | cut -d" " -f39' > /tmp/libvirt-uuids_$(date +%F).txt
cat /tmp/libvirt-uuid_$(date +%F).txt   
fi

#confirmation if no 
 if [[ $REPLY =~ ^[Nn]$ ]]
  then
    echo "what a waste of time"

fi
