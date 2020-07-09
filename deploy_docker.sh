#!/bin/env bash

# Auth: braior
# Email: braior@163.com
# Datetime:2019.7.31

systemctl stop docker
rpm -qa |grep docker >/dev/null 2>&1
if [ $? -eq 0 ];then
	read -p "Your machine has docker installed, if you want to uninstall please enter yes, or enter any key to exit:" choose
	if [[ "$choose" == "yes" ]];then
    	yum remove -y docker \
	                  docker-client \
	                  docker-client-latest \
	                  docker-common \
	                  docker-latest \
	                  docker-latest-logrotate \
	                  docker-logrotate \
	                  docker-selinux \
	                  docker-engine-selinux \
	                  docker-engine \
	                  docker-ce 
	    find /etc/systemd -name '*docker*' -exec rm -rf {} \; 
	    find /lib/systemd -name '*docker*' |xargs rm -rf
	    # 删除以前已有的镜像和容器，非必要
	    # rm -rf /var/lib/docker
	    rm -rf /var/lib/docker
	else
		exit 0
	fi
fi
echo "Installing docker,please wait a moment..."
yum install -y yum-utils device-mapper-persistent-data lvm2 >/dev/null 2>&1
if [ $? -eq 0 ];then
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo >/dev/null 2>&1
    # yum list docker-ce --showduplicates |sort -r 
    # read -p "Please select the specified version.such as:[17.03.2]:" ver
    yum install -y docker-ce
    # docker version >/dev/null 2>&1
    systemctl start docker && systemctl enable docker 
    if [ $? -eq 0 ];then
        echo "Docker was installed finish!"
    fi
fi

