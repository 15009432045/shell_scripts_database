#!/bin/env bash

# 设计一个shell脚本来备份数据库，首先在本地服务器上保存一份数据，然后再远程拷贝一份，本地保存一周的数据，远程保存一个月。
# 假定，我们知道mysql root账号的密码，要备份的库为 1000phone ，本地备份目录为/bak/mysql.
# 远程服务器ip为192.168.123.30，假设远程主机备份目录已挂载在本地/backup 目录下. 写完脚本后，需要加入到cron中，每天凌晨3点执行。

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/mysql/bin

week=$(date +%w)
days=$(date +%d)

passwd="Zxs142857.*"
mysql_bak_dir=/bak/mysql
remote_bak_dir=/backup
echo "mysql backup begin at $(date +%F-%T)." >>/log/backup_mysql.log
mysqldump -uroot -p$passwd wordpess >$mysql_bak_dir/$week.sql
cp -rf $mysql_bak_dir/$week.sql $remote_bak_dir/$days.sql
echo "mysql backup end at $(date +%F-%T)." >>/log/backup_mysql.log
