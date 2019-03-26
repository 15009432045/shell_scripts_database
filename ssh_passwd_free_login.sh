#!/bin/env bash


rpm -qa |grep expect
if [ $? -ne 0 ];then
    yum -y install expect
fi

user="root"
passwd="123456"
ip="192.168.59.3"

/usr/bin/expect <<-EOF
    spawn ssh-keygen
        expect {
    	"*:" { send "\r";exp_continue }
        "*:" { send "\r" }
    	"*:" { send "\r" }
    	}
    spawn ssh-copy-id $user@$ip
        expect {
    	"yes/no" { send "yes\r";exp_continue }
        "password:" { send "$passwd\r" }
    	}
expect eof
EOF

