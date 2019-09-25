#!/bin/env bash
# Email:                hyb_admin@163.com
# Description:          This script can achieve ssh password-free login, 
#                       and can be deployed in batches, configuration

# 密钥对不存在则创建密钥
[ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -t rsa -p '' &>/dev/null
while read line;do
        # 提取文件中的ip
        ip=`echo $line | cut -d " " -f1`
        # 提取文件中的用户名            
        user_name=`echo $line | cut -d " " -f2`
        # 提取文件中的密码
        pass_word=`echo $line | cut -d " " -f3`
expect <<EOF
        # 复制公钥到目标主机
        spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user_name@$ip
        expect {
                "yes/no" { send "yes\n";exp_continue}
                "password" { send "$pass_word\n"}
        }
        expect eof
EOF
  
done < /root/host_ip.txt
