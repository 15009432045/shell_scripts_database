#!/bin/env bash



systemctl stop firewalld && systemctl disable firewalld
sed -ri /SELINUX=enabled/SELINUX=disabled/g /etc/selinux/config
setenforce 0
rm -rf /etc/yum.repos.d/epel.repo && rm -rf /etc/yum.repos.d/epel-testing.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo 
yum clean all
yum make cache
yum -y update
yum -y groupinstall "Development Tools"

yum -y install gcc gcc-c++  ncurses-devel bison libgcrypt perl make cmake wget

mkdir -p /opt/mysql-5.7.25 && cd /opt/mysql-5.7.25
rm -rf /opt/mysql-5.7.25/*
cp /opt/my.cnf.bak /opt/mysql-5.7.25/my.cnf

wget  https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.25.tar.gz

groupadd mysql
useradd -M -g mysql -s /sbin/nologin mysql
rm -rf /usr/local/mysqld
mkdir -p /usr/local/mysqld/{data,mysql,log,tmp}
chown -R mysql:mysql /usr/local/mysqld/*
tar xf mysql-boost-5.7.25.tar.gz
cd mysql-5.7.25

cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysqld/mysql \
-DMYSQL_DATADIR=/usr/local/mysqld/data \
-DWITH_BOOST=/opt/mysql-5.7.25/mysql-5.7.25/boost \
-DDEFAULT_CHARSET=utf8

if [ $? -eq 0 ];then
	make
	if [ $? -eq 0 ];then
		make install
		if [ $? -eq 0 ];then
			echo "export PATH=$PATH:/usr/local/mysqld/mysql/bin" >>/etc/profile
			                        source /etc/profile
                        mv /etc/my.cnf /etc/my.cnf.bak
                        #cp -rf /usr/local/mysqld/mysql/mysql-test/include/default_mysqld.cnf /etc/my.cnf

                        cp -f /opt/my.cnf.bak /etc/my.cnf

                        /usr/local/mysqld/mysql/bin/mysqld --defaults-file=/etc/my.cnf --initialize --user='mysql'
                        mysqld_safe --defaults-file=/etc/my.cnf &
			sleep 15s
                        ln -s /usr/local/mysqld/tmp/mysql.sock /tmp/mysql.sock
                        cp -f /usr/local/mysqld/mysql/support-files/mysql.server /etc/init.d/mysqld
                        chkconfig --add mysqld
                        chkconfig mysqld on
                        if [ $? -eq 0 ];then
                                printf "install succeed!\n"
                                passwd=`grep "password" /usr/local/mysqld/log/mysql_error.log |awk -F " " 'NR==1 {print $NF}'`
        			mysql --connect-expired-password -uroot -p$passwd -e "alter user 'root'@'localhost' identified by 'Zxs142857.*';"
				if [ $? -eq 0 ];then
                                        echo "all finished!!!\n"
                                else
                                        echo "xiu gai mysql passwd failed!!!\n"
                                        exit
                                fi
                        fi
	
		else
			printf "make install error!!\n"	
			exit
		fi
	else
		printf "make error!!!\n"
		exit
	fi
else
	printf "cmake error!!!!\n"
	exit
fi













