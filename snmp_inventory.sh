#!/bin/sh
###############################################################################
#                                                                             #
# A script for checking info about printers with SNMP                         #
# Written by Farid Joubbi 2014-10-02                                          #
#                                                                             #
# USAGE:                                                                      #
# ./printer_info FILENAME                                                     #
# FILENAME is a file containing one hostname per row.                         #
#                                                                             #
###############################################################################


if [ $# -lt 1 ]; then
  echo "No file with hostnames defined!"
  echo "Quitting!"
  exit 1
fi

SNMPOPT="/usr/bin/snmpget -v 1 -c public -Ov -t 0.5 -Lo"




echo "Checking these hosts:"
echo "IP ADDRESS/NAME, HOSTNAME, MODEL, LOCATION, MAC ADDRESS, SERIAL"
while read LINE
do
  # Check if a printer answers
  $SNMPOPT $LINE .1.3.6.1.2.1.25.3.2.1.2.1 > /dev/null
  if [[ $? == 0 ]]; then
    serial="N/A"
    mac="N/A"
    hostname=`$SNMPOPT $LINE .1.3.6.1.2.1.1.5.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    #contact=`$SNMPOPT $LINE .1.3.6.1.2.1.1.4.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    location=`$SNMPOPT $LINE .1.3.6.1.2.1.1.6.0 | /bin/sed -e 's/\STRING: //g' | tr '[<>]' '_'`
    model=`$SNMPOPT $LINE .1.3.6.1.2.1.25.3.2.1.3.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`

    # HP specific stuff
    echo "$model" | /bin/grep HP > /dev/null
    if [ $? == 0 ]; then
      serial=`$SNMPOPT $LINE .1.3.6.1.2.1.43.5.1.1.17.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.2 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    fi

    # Zebra specific stuff
    echo "$model" | /bin/grep Zebra > /dev/null
    if [ $? == 0 ]; then
      mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.3 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
    fi



    # Canon specific stuff
    echo "$model" | /bin/grep Canon > /dev/null
    if [ $? == 0 ]; then
      mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      echo "$model" | /bin/grep iR-ADV > /dev/null
      if [ $? == 0 ]; then
        serial=`$SNMPOPT $LINE .1.3.6.1.2.1.43.5.1.1.17.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
      fi
    fi





#    version=`$SNMPOPT $LINE .1.3.6.1.2.1.47.1.1.1.1.10.1001 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
#    model=`$SNMPOPT $LINE .1.3.6.1.2.1.25.3.2.1.3.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
#    serial=`$SNMPOPT $LINE .1.3.6.1.2.1.43.5.1.1.17.1 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
#    mac=`$SNMPOPT $LINE .1.3.6.1.2.1.2.2.1.6.2 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`


    echo "$model" | /bin/grep OID > /dev/null
    if [ $? == 0 ]; then
      model="N/A"
    fi


    echo "$LINE" = "$hostname", "$model", "$location", "$mac", "$serial"
  fi

done < $1


