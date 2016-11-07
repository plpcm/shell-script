#!/bin/bash

#45分mysql全备,暂停监控

[ `date '+%M'` == 45 ] && exit 0

IP=`/sbin/ifconfig eth1 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "` 
TIME=`date '+%F %H:%M'`
WORK_PATH="/sh/monitor/data"
EMAIL="@139.com"


#监控cpu使用率
#cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $5}' | cut -f 1 -d "."`  
cpu_idle=`vmstat 1 3 |tail -1|awk '{print $15}'`  
cpu_used=`expr 100 - $cpu_idle`
if [ $cpu_idle -lt 20 ]
then
  echo "$TIME $IP服务器 cpu已使用$cpu_used%,使用率已经超过80%,请及时处理。">> $WORK_PATH/performance_$(date +%Y%m%d).log
  echo "$TIME $IP服务器 cpu已使用$cpu_used%,使用率已经超过80%,请及时处理！！！" | mail -s "$IP服务器cpu告警" $EMAIL
else
  echo "$TIME $IP服务器 cpu已使用$cpu_used%,使用率正常">>$WORK_PATH/performance_$(date +%Y%m%d).log
fi
#监控交换分区
swap_total=`free -m | grep Swap | awk '{print  $2}'`
swap_free=`free -m | grep Swap | awk '{print  $4}'`
swap_used=`free -m | grep Swap | awk '{print  $3}'`
if [ $swap_used -ne 0 ]
then
  swap_per=0`echo "scale=2;$swap_free/$swap_total" | bc`
  swap_warn=0.10
  swap_now=`expr $swap_per \> $swap_warn`
  if [ $swap_now -eq 0 ]
  then
    echo "$TIME $IP服务器 swap交换分区已使用$swap_used M，剩余不足20%，使用率已经超过80%，请及时处理。">>$WORK_PATH/performance_$(date +%Y%m%d).log
    echo "$TIME $IP服务器 swap交换分区只剩下 $swap_free M 未使用，剩余不足20%, 使用率已经超过80%, 请及时处理。" | mail -s "$IP服务器内存告警" $EMAIL
  else
    echo "$TIME $IP服务器 swap交换分区已使用$swap_used M，使用率正常">>$WORK_PATH/performance_$(date +%Y%m%d).log
  fi
else
     echo "$TIME $IP服务器交换分区未使用"  >>$WORK_PATH/performance_$(date +%Y%m%d).log
fi
#监控内存
mem_total=`free -m | grep Mem | awk '{print  $2}'`
mem_free=`free -m | grep + | awk '{print  $4}'`
mem_used=`free -m | grep + | awk '{print  $3}'`
if [ $mem_used -ne 0 ]
then
  mem_per=0`echo "scale=2;$mem_free/$mem_total" | bc`
  mem_warn=0.15
  mem_now=`expr $mem_per \> $mem_warn`
  if [ $mem_now -eq 0 ]
  then
    echo "$TIME $IP服务器 内存已使用 $mem_used M，剩余不足20%，使用率已经超过80%，请及时处理。">>$WORK_PATH/performance_$(date +%Y%m%d).log
    echo "$TIME $IP服务器 内存只剩下 $mem_free M 未使用，剩余不足20%, 使用率已经超过80%, 请及时处理。" | mail -s "$IP服务器内存告警" $EMAIL
  else
    echo "$TIME $IP服务器 内存已使用$mem_used M，使用率正常">>$WORK_PATH/performance_$(date +%Y%m%d).log
  fi
fi
#监控磁盘空间 / 分区
disk_sda1=`df -h | grep '/dev/xvda1 ' | awk '{print $5}' | cut -f 1 -d "%"`
if [ $disk_sda1 -gt 90 ]
then
  echo "$TIME $IP服务器 /根分区 使用率为$disk_sda1%,请及时处理。">>$WORK_PATH/performance_$(date +%Y%m%d).log
  echo "$TIME $IP服务器 /根分区 使用率已经超过80%,请及时处理。 " | mail -s "$IP服务器硬盘/分区告警" $EMAIL
else
  echo "$TIME $IP服务器 /根分区 使用率为$disk_sda1%,使用率正常">>$WORK_PATH/performance_$(date +%Y%m%d).log
fi

#监控登录用户数
#users=`uptime |awk '{print $6}'`
users=` w|grep -c pts`
if [ $users -gt 88 ]
then
  echo "$TIME $IP服务器用户数已经达到$users个，请及时处理。">>$WORK_PATH/performance_$(date +%Y%m%d).log
  echo "$TIME $IP服务器用户数已经达到$users个，请及时处理。" | mail -s "$IP服务器用户登录数告警" $EMAIL
else
  echo "$TIME $IP服务器当前登录用户为$users个，情况正常">>$WORK_PATH/performance_$(date +%Y%m%d).log
fi
