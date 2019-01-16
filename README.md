# snmp_inventory

A script that presents information about SNMP enabled devices.
Originally written for helping with making an inventory of SNMPv1 enabled pritners.

A good way to make a list of IP addresses to use as an input for this script:
`$ nmap -T4 -sU -p 161 --script snmp-sysdescr --script-args creds.snmp=public -oG - 192.168.1.0/24 --open | grep 'open/udp' | cut -d' ' -f2`

### Usage
`$ ./snmp_inventory.sh filename.txt`

## Version history



___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

