#!/bin/bash

# Author: braior
# Email: braior@163.com
# Github: https://github.com/braior

export IP=`ifconfig | grep Ethernet -A1 | grep -v Link | awk -F[' ':]+ '{print $4}'`
MYUSER=root
MYPASS="password"
MYSQL_PATH=/usr/bin/
MYSQL_CMD="$MYSQL_PATH/mysql -u$MYUSER -p$MYPASS"

SlaveStatus=($($MYSQL_CMD  -e "show slave status\G" | egrep "_Running"|awk '{print $NF}'))

if [ "${SlaveStatus[0]}" = "No" ] || [ "${SlaveStatus[1]}" = "No" ]
then
    systemctl stop keepalived
fi

