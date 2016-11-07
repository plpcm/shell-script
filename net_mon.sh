#! /bin/bash

IP=`/sbin/ifconfig eth1 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`
WORK_PATH="/sh/monitor/data"
EMAIL="@139.com"

typeset in in_old dif_in dif_in1 dif_out1
typeset out out_old dif_out
in_old=$(cat /proc/net/dev | grep eth1 | sed 's=^.*:==' | awk '{ print $1 }' )  ##直到上一秒总共IN的网络流量
out_old=$(cat /proc/net/dev | grep eth1 | sed 's=^.*:==' | awk '{ print $9 }')  ##直到上一秒总共OUT的网络流量
sleep 1  ## 刷新时间
in=$(cat /proc/net/dev | grep eth1 | sed 's=^.*:==' | awk '{ print $1 }')  ##直到本秒IN的网络流量
out=$(cat /proc/net/dev | grep eth1 | sed 's=^.*:==' | awk '{ print $9 }')  ##直到OUT的网络流量
dif_in=$(((in-in_old)/1024))  ##每一秒的IN的流量
dif_in1=$(((dif_in*8)/1024))   ##每一秒的IN的带宽使用量
dif_out=$(((out-out_old)/1024))  ##每一秒的OUT的流量
echo "----------------$IP-----------------" >> $WORK_PATH/net_data_`date +%F`
echo -e "`date +%F" "%H:%M` IN: ${dif_in} KBytes\tOUT: ${dif_out} KBytes " >> $WORK_PATH/net_data_`date +%F`
dif_out1=$(((dif_out*8)/1024))  ##每一秒的OUT的带宽使用量
echo -e "`date +%F" "%H:%M` IN: ${dif_in1} Mbps\tOUT: ${dif_out1} Mbps" >> $WORK_PATH/net_data_`date +%F`

if [ ${dif_in1} -gt 3 -o ${dif_out1} -gt 3 ];
then
  #echo ${dif_in1}
  flag=`cat $WORK_PATH/flag`
  : $[flag++]
  echo $flag > $WORK_PATH/flag
  if [ $flag -gt 5 ];
  then
    echo -e "`date +%F" "%H:%M` IN: ${dif_in1} Mbps\t\tOUT: ${dif_out1} Mbps" | mail -s "服务器 $IP 流量异常持续五分钟"  $EMAIL
    echo 0 > $WORK_PATH/flag
  fi
else
  echo 0 > $WORK_PATH/flag
fi
