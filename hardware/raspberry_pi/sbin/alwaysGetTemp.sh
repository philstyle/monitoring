#!/bin/bash
while [ 1 == 1 ]
do
  /sbin/getTemp.sh >> /var/log/getTemp.`date +%j`.log 2>&1
done
