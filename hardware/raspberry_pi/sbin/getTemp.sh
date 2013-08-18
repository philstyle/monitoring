#!/bin/bash
DEVICES=/sys/bus/w1/devices
CURDIR=`pwd`
HOST=`cat /etc/hostname`
function getTemp {
  DEVICES=$1
  SENSOR=$2 #(minus w1_slave)
  
  OUTPUT=`cat $DEVICES/$SENSOR/w1_slave`
  TEMP=`echo $OUTPUT | grep "YES" | awk -F't=' '{print $2}'`
  COUNT=0
  while [ x$TEMP == x ]
  do
    echo `date +%F_%X` "trying again... "$OUTPUT
    OUTPUT=`cat $DEVICES/$SENSOR/w1_slave`
    TEMP=`echo $OUTPUT | grep "YES" | awk -F't=' '{print $2}'`
    COUNT=$(($COUNT + 1))
    if [ $COUNT -gt "5" ]
    then
      #device not responding
      echo `date +%F_%X` "${SENSOR} not responding. Skipping..."
      return 1
    fi
  done
  CELCIUS=`echo $OUTPUT | awk -F't=' '{print $2}'`
  FARENHEIT=$(echo "scale=3;(((9/5) * $CELCIUS) + 32000)/1000"|bc)
  INT_TEMP=`echo "(${FARENHEIT}/1)"|bc`
  if [ $INT_TEMP -lt "-40" ] || [ $INT_TEMP -gt "250" ]
  then
    #bad temperature
    echo `date +%F_%X` "Bad temp from ${SENSOR}: ${FARENHEIT} F"
  else
    #echo "$SENSOR: $FARENHEIT F"
    echo "${HOST}.DS18B20.${SENSOR}" $FARENHEIT `date +%s` | nc localhost 2013
  fi
}



for SENSOR in `ls -1 ${DEVICES} | grep '^28'` 
do
  getTemp $DEVICES $SENSOR
done


