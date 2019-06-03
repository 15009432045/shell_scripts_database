#!/bin/bash	

# Author: braior
# Email: braior@163.com
# Github: https://github.com/braior

/usr/bin/curl -I http://localhost &>/dev/null	
if [ $? -ne 0 ];then									    	
	systemctl stop keepalived.service
fi						
