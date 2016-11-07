#! /bin/bash

EMAIL="@139.com"

SEND="/sh/business/send.py"

modifytime=`stat /php-fpm/www-error.log|grep Modify|cut -d' ' -f2`

[ ! "$modifytime" == "`date +%Y-%m-%d`" ] && exit 0

FH=`ls -l /php-fpm/www-error.log |awk '{print $8}'|cut -d':' -f1`
FM=`ls -l /php-fpm/www-error.log |awk '{print $8}'|cut -d':' -f2`
H=`date +"%H"`
M=`date +"%M"`


if [ `expr $H - $FH` -eq 0 ] ;then
	if [ "`expr $M - $FM`" -lt "2" ] ;then
		msg=`tail -1 /php-fpm/www-error.log|sed 's/\ Asia\/Singapore//g'`
		$SEND weixin "NOTICE_SERVER" "php_code_error" "$msg"
		echo -e "`expr $M - $FM` 分钟"
	fi

elif [ `expr $H - $FH - 1` -eq 0 ] ;then
	if [ "`expr $M - $FM + 60`" -lt "2" ] ;then
		msg=`tail -1 /php-fpm/www-error.log|sed 's/\ Asia\/Singapore//g'`
		$SEND weixin "NOTICE_SERVER" "php_code_error" "$msg"
		echo -e "`expr $M - $FM + 60`  分钟" 
	fi
else

	echo  "yes"
fi

