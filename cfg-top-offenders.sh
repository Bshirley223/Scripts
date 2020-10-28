#!/bin/bash

# 1. list computes function
sudo salt -C 'I@nova:compute' test.ping | grep -v True | sort -n

# 2. prompt variable function
echo "which compute are you checking"
echo "example: cmp001 or cmp001.us.intcloud.mirantis.net"

# 3. set variable function
read varname

# 4. print confirmation to user
echo script checking $varname


# 5. set top-offending-pids.txt file on nova host
sudo salt "*$varname*"  cmd.shell "ps -ef | grep qemu-system-x86_64 | awk '{print \$2}'  shell='/bin/bash' > /tmp/top-offending-pids.txt"

# 6. list out top offending uuids
sudo salt "*$varname*"  cmd.shell "for i in /$(cat /tmp/top-offending-pids.txt); do  ps aux | grep \$i | grep -oP '(?<=uuid ).+?(?=-smbios)' >  /tmp/openstack_high_cpu_allocation_uuids.txt ;done && head -5 /tmp/openstack_high_cpu_allocation_uuids.txt"
