#!/bin/sh
###############################################################################
#                                                                             #
# A script for checking info about printers with SNMP                         #
# Written by Farid Joubbi 2014-10-02                                          #
#                                                                             #
# USAGE:                                                                      #
# ./printer_info FILENAME                                                     #
# FILENAME is a file containing one hostname per row.                         #
#
# Version 2.0 2019-01-16 Renamed file to snmp_inventory                                                                             #
# Version 1.0 2014-10-02 Initial release named printer_info.sh                #
#                                                                             #
# Licensed under the Apache License Version 2.0                               #
# Written by farid@joubbi.se                                                  #
#                                                                             #
###############################################################################





if [ $# -lt 1 ]; then
  echo "No file with hostnames defined!"
  echo "Quitting!"
  exit 1
fi

SNMPOPT="/usr/bin/snmpget -v 1 -c public -Ov -t 0.5 -Lo"



echo "Checking these hosts:"
echo "IP ADDRESS/NAME, HOSTNAME, MODEL, LOCATION, CONTACT, MAC ADDRESS, SERIAL"
while read LINE
do
  hostname="N/A"
  model="N/A"
  location="N/A"
  contact="N/A"
  mac="N/A"
  serial="N/A"


  # Check if device answers and get general mandatory variables
  #hostname=`$SNMPOPT $LINE .1.3.6.1.2.1.1.5.0 > /dev/null 2>&1`
  $SNMPOPT $LINE .1.3.6.1.2.1.1.5.0 > /dev/null 2>&1
  if [[ $? == 0 ]]; then
#    hostname=`echo $hostname | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'` 
    hostname=`$SNMPOPT $LINE .1.3.6.1.2.1.1.5.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    contact=`$SNMPOPT $LINE .1.3.6.1.2.1.1.4.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    location=`$SNMPOPT $LINE .1.3.6.1.2.1.1.6.0 | /bin/sed -e 's/\STRING: //g' | tr '[<>]' '_'`

    #hrDeviceDescr A textual description of this device, including the device's manufacturer and revision, and optionally, its serial number.
    $SNMPOPT $LINE .1.3.6.1.2.1.25.3.2.1.3.1 > /dev/null 2>&1
    if [[ $? == 0 ]]; then
      model=`$SNMPOPT $LINE .1.3.6.1.2.1.25.3.2.1.3.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    else
      $SNMPOPT $LINE .1.3.6.1.2.1.1.2.0 > /dev/null 2>&1
      if [[ $? == 0 ]]; then
        sysObjectID=`$SNMPOPT $LINE .1.3.6.1.2.1.1.2.0`
        echo "$sysObjectID" | /bin/grep '.8691.' > /dev/null 
        if [[ $? == 0 ]]; then
          model="Moxa"
        fi
      fi
    fi

    # HP specific stuff
    echo "$model" | /bin/grep 'HP' > /dev/null
    if [ $? == 0 ]; then
      serial=`$SNMPOPT $LINE .1.3.6.1.2.1.43.5.1.1.17.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.2 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    fi

    # Zebra specific stuff
    echo "$model" | /bin/grep 'Zebra' > /dev/null
    if [ $? == 0 ]; then
      $SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.3 > /dev/null 2>&1
      if [[ $? == 0 ]]; then
        mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.3 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      else
        mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.2 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      fi
    fi



    # Canon specific stuff
    echo "$model" | /bin/grep 'Canon' > /dev/null
    if [ $? == 0 ]; then
      mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      echo "$model" | /bin/grep 'iR-ADV' > /dev/null
      if [ $? == 0 ]; then
        serial=`$SNMPOPT $LINE .1.3.6.1.2.1.43.5.1.1.17.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      fi
    fi



  else
    hostname="N/A"
  fi

echo "$LINE" = "$hostname", "$model", "$location", "$contact", "$mac", "$serial"
done < $1


