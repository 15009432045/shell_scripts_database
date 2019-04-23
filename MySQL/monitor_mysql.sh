#!/bin/env bash

# 假设，当前MySQL服务的root密码为123456，写脚本检测MySQL服务是否正常（比如，可以正常进入mysql执行
# show processlist），并检测一下当前的MySQL服务是主还是从，如果是从，请判断它的主从服务是否异常。如果是主，则不需要做什么。

passwd="zxs142857.*"
Mysql_c="mysql -uroot -p'$passwd'"
$Mysql_c -e "show processlist" >/tmp/mysql_pro.log 2>/tmp/mysql_log.err
n=$(wc -l /tmp/mysql_log.err |awk '{print $1}')

if [ $n -gt 0 ];then
	echo "mysql service sth wrong."
else
	$Mysql_c -e "show slave status\G" >/tmp/mysql_s.log
	n1 = $(wc -l /tmp/mysql_s.log |awk '{print $1}')

	if [ $n1 -gt 0 ];then
		y1=$(grep 'Slave_IO_Running:' /tmp/mysql_s.log |awk -F: '{print $2}' |sed 's/ //g')
		y2=$(grep 'Slave_SQL_Running:' /tmp/mysql_s.log |awk -F: '{print $2}' |sed 's/ //g')

		if [ $y1 == "Yes" ] && [ $y2 == "Yes" ];then
			echo "slave status good."
		else
			echo "slave down."
		fi
	fi
fi
