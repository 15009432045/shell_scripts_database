#!/bin/bash											        	
/usr/bin/curl -I http://localhost &>/dev/null	
if [ $? -ne 0 ];then									    	
	systemctl stop keepalived.service
fi						
