
#!/bin/env bash


# Author: xszhang
# Email: szgoingo@gmail.com
# Date: 2019/03/23
# Usage: System initialization and LNAP environment building

systemctl stop firewalld && systemctl disable firewalld
sed -ri s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
setenforce 0


printf "\e[1;32mChanging Yum source...\e[0m\n"
mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#rpm -ivh  http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#rpm -Uvh http://mirrors.kernel.org/fedora-epel/epel-release-latest-7.noarch.rpm
#rpm -Uvh http://ftp.iij.ad.jp/pub/linux/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm 
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo 
yum clean all && yum makecache

printf "\e[1;32mThe system is being initialized...\e[0m\n"
yum -y install vim net-tools 'bind-utils' lrzsz wget bash-completion nc ntpdate
ntpdate -b ntp1.aliyun.com 

if [ ! -f ./install_info.log ];then
	touch ./install_info.log
else
	>./install_info.log
fi

function CHECK_URL() {
	export project
    	curl -o ./web_info.txt http://localhost 
    	if [ $? -eq 0 ];then
        	printf "`date +%F_%H:%M:%S` $project  was installed and runnging successful!\n" >>./install_info.txt
    	else
        	printf "`date +%F_%H:%M:%S` $project runnging error!\n" >>./install_info.txt
    	fi
}

function install_nginx() {
	
	local project="Nginx"
	rpm -qa |grep nginx
	if [ $? -eq 0 ];then
        	printf "The system has installed nginx!\n"
        	systemctl restart nginx && systemctl enable nginx
		\cp -f ./default.html /etc/nginx/conf.d/default.html 
		CHECK_URL
	else 
   		rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm			
		yum -y install nginx
   		systemctl start nginx && systemctl enable nginx
		\cp -f ./default.html /usr/share/nginx/html/default.html
		CHECK_URL
    fi
}
         
function install_php {
	
	local project="PHP"
	echo "<?php phpinfo(); ?>" >/usr/share/nginx/html/index.php
   	if rpm -qa |grep php ;then
   		printf "The system has installed PHP!\n"
		systemctl restart php73-php-fpm && systemctl enable php73-php-fpm
		CHECK_URL
   	else
   		rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm 
   		yum -y install php73-php php73-php-fpm php73-php-mysql php73-php-xml php73-php-gd php73-php-devel php73-php-mbstring php73-php-mcrypt
   		systemctl start php73-php-fpm && systemctl enable php73-php-fpm
		CHECK_URL
   	fi
}


function setup_mysql_user() {
	
	local old_passwd=`grep "password" /var/log/mysqld.log |awk -F " " 'NR==1 {print $11}'`
	local new_passwd="Zxs142857.*"
	mysql -uroot -p"$old_passwd" --connect-expired-password -e "alter user 'root'@'localhost' identified by '$new_passwd';"
	mysql -uroot -p"$new_passwd" -e "create database wordpess;"
}

function install_mysql() {
	
	echo "<?php
\$link = mysql_connect('localhost', 'root', 'Zxs142857.*');
if (!\$link) {
	die('Could not connect: ' . mysql_error());
	}
echo 'Connected successfully';
mysql_close(\$link);
?>" >/usr/share/nginx/html/index.php
        
	local project="MySQL"
	if  rpm -qa |grep mysql-community-server;then
  		printf "The system has installed database!\n"
		systemctl restart mysqld && systemctl enable mysqld
		CHECK_URL
   	else
   		#wget -P /opt https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm
        	#rpm -ivh /opt/mysql80-community-release-el7-1.noarch.rpm
		wget -P /opt http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
		rpm -ivh /opt/mysql57-community-release-el7-8.noarch.rpm
   		#sed -ri '/\[mysql80-community\]/{n;n;n;s/enabled=1/enabled=0/}' /etc/yum.repos.d/mysql-community.repo
   		#sed -ri '/\[mysql57-community\]/{n;n;n;s/enabled=0/enabled=1/}' /etc/yum.repos.d/mysql-community.repo
   		yum -y install mysql-community-server
   		systemctl restart mysqld && systemctl enable mysqld
		setup_mysql_user
		CHECK_URL
	fi
}

install_nginx
install_php
install_mysql


