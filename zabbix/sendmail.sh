#set from=braior@163.com smtp=smtp.163.com 
#set smtp-auth-user=braior@163.com smtp-auth-password=ZXS142857
#set smtp-auth=login

#!/bin/sh
#export.UTF-8
echo "$3" | sed s/'\r'//g | mailx -s "$2" $1
