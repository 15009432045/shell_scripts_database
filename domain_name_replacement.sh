#!/bin/env bash

# Auth: braior
# Email: braior@163.com
# Date: 2019.08.01

# 定义相关变量
OLD_DOMAIN_NAME=ukex.com
NEW_DOMAIN_NAME=abc.com
OLD_CONF_SUFFIX=ukex.com.conf
NEW_CONF_SUFFIX=abc.com.conf

SSL_CERT_PATH="/usr/local/nginx/conf/ssl/"
OP_DIR=./vhost

# 备份要操作的目录
cp -r $OP_DIR $NEW_DOMAIN_NAME

if [ -f ./temp.txt ];then
    rm -rf ./temp.txt
fi

# 遍历vhost目录下的所有以.conf结尾的文件，并将文件名追加到temp.txt中
for file in `ls $NEW_DOMAIN_NAME`
do
    if [[ "${file#*.}" = "${OLD_CONF_SUFFIX}" ]];then 
        echo "$file" >>./temp.txt

        # 修改server_name
        sed -ri "/server_name/{s/$OLD_DOMAIN_NAME/$NEW_DOMAIN_NAME/g}" $NEW_DOMAIN_NAME/$file
        
        # 修改ssl证书
        new_ssl_cert="${SSL_CERT_PATH}${file%%.*}.${NEW_DOMAIN_NAME}.crt"
        new_ssl_cert_key="${SSL_CERT_PATH}${file%%.*}.${NEW_DOMAIN_NAME}.key"

        # sed -i "/ssl_certificate /c$new_ssl_cert" $NEW_DOMAIN_NAME/$file
        # sed -i "/ssl_certificate_key /c$new_ssl_cert_key" $NEW_DOMAIN_NAME/$file

        sed -ri "s#(ssl_certificate )[^;]*#\1$new_ssl_cert#" $NEW_DOMAIN_NAME/$file
        sed -ri "s#(ssl_certificate_key )[^;]*#\1$new_ssl_cert_key#" $NEW_DOMAIN_NAME/$file
        
        # 更名
        mv $NEW_DOMAIN_NAME/$file $NEW_DOMAIN_NAME/${file%%.*}.${NEW_CONF_SUFFIX}
        # echo ${file_name%%.*}.${NEW_CONF_SUFFIX}

    fi
done

