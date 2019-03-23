
#!/bin/env bash

#  

printf "\e[1;32mChanging Yum source...\e[0m\n"
mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
rpm -ivh  http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum clean all && yum makecache

printf "\e[1;32mThe system is being initialized...\e[0m\n"
yum -y install vim net-tools 'bind-utils' lrzsz wget bash-completion nc  

printf "\e[1;32m
#################################################
##           system manager toos 1.0           ##
##                1).安装 nginx                ##
##                2).安装 mysql                ##
##                3).安装 php7.3               ##
##                4).exit                      ##
#################################################
\e[0m"
printf "\e[1;31m please input your choices:\e[0m " && read var

case $var in
    1)
	if [ -f /etc/nginx/nginx.conf ];then
		printf "The system has installed nginx!\n"
	else
		rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm			
		yum -y install nginx
		systemctl start nginx && systemctl enable nginx
	fi
        ;;
    2)	
	if  rpm -qa |grep mysql-community-server;then
		printf "The system has installed database!\n"

	else
		wget -P /opt https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm
	        rpm -ivh /opt/mysql80-community-release-el7-1.noarch.rpm
		sed -ri '/\[mysql80-community\]/{n;n;n;s/enabled=1/enabled=0/}' /etc/yum.repos.d/mysql-community.repo
		sed -ri '/\[mysql57-community\]/{n;n;n;s/enabled=0/enabled=1/}' /etc/yum.repos.d/mysql-community.repo
		yum -y install mysql-community-server
		systemctl start mysql && systemctl enable mysql
	fi
        ;;
    3)
	if rpm -qa |grep php ;then
		printf "The system has installed PHP"
	else
		rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm 
		yum -y install php73-php php73-php-fpm php73-php-mysql php73-php-xml php73-php-gd php73-php-devel php73-php-mbstring php73-php-mcrypt
		systemctl start php73-php-fpm && systemctl enable php73-php-fpm
	fi
	;;
    4)
	exit
        ;;
    *)
	printf "please input "1","2","3":\n"
        ;;
esac

