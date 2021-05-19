#!/bin/bash
ListeningPort=`netstat -an | grep ":8560" | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l`
if [ $ListeningPort -eq 0 ]
then
 {
  echo "`date` : listener port is down">>/home/chia/.chia/mainnet/log/debug.log
  # 如果8560端口down了，重启服务

  cd /home/chia/chia-blockchain && . ./activate && chia start harvester -r &


 }
else
 {
   echo "`date` : 8560端口正常" >>/home/chia/.chia/mainnet/log/debug.log
  }
fi
