#!/bin/env bash

# Auth: braior
# Email: *
# Date: 2019.12.16

CN_CA="root"
CN="ukex.com"
CLIENT_PASS="zKH1t9nVPjCihfjv"

cd /root/nginx_ssl
# 1)创建根证私钥
openssl genrsa -out root-key.key 2048
# 2)创建根证书请求文件
openssl req -new -out root-req.csr -key root-key.key -subj "/C=CN/ST=CQ/L=CQ/O=UKDE/OU=UKDE/CN=$CN_CA"
# 3)自签根证书
openssl x509 -req -in root-req.csr -out root-cert.cer -signkey root-key.key -CAcreateserial -days 3650

# 4)生成p12格式根证书,密码填写CLIENT_PASS
/usr/bin/expect <<-EOF
    spawn openssl pkcs12 -export -clcerts -in root-cert.cer -inkey root-key.key -out root.p12
        expect {
    	"Password:" { send "$CLIENT_PASS\r";exp_continue }
        "Password:" { send "$CLIENT_PASS\r" }
    	}
expect eof
EOF

# 5)生成服务端key
openssl genrsa -out server-key.key 2048
# 6)生成服务端请求文
openssl req -new -out server-req.csr -key server-key.key -subj "/C=CN/ST=CQ/L=CQ/O=UKDE/OU=UKDE/CN=$CN"

# 7)生成服务端证书（root证书，rootkey，服务端key，服务端请求文件这4个生成服务端证书）
openssl x509 -req -in server-req.csr -out server-cert.cer -signkey server-key.key -CA root-cert.cer -CAkey root-key.key -CAcreateserial -days 3650

# 8)生成客户端key
openssl genrsa -out client-key.key 2048
# 9)生成客户端请求文件
openssl req -new -out client-req.csr -key client-key.key -subj "/C=CN/ST=CQ/L=CQ/O=UKDE/OU=UKDE/CN=$CN"
# 10)生成客户端证书（root证书，rootkey，客户端key，客户端请求文件这4个生成客户端证书）
openssl x509 -req -in client-req.csr -out client-cert.cer -signkey client-key.key -CA root-cert.cer -CAkey root-key.key -CAcreateserial -days 3650
# 11)生成客户端p12格式根证书(密码设置CLIENT_PASS)
/usr/bin/expect <<-EOF
    spawn openssl pkcs12 -export -clcerts -in client-cert.cer -inkey client-key.key -out client.p12
        expect {
    	"Password:" { send "$CLIENT_PASS\r";exp_continue }
        "Password:" { send "$CLIENT_PASS\r" }
    	}
expect eof
EOF
mv /usr/local/nginx/houtaissl/{root-cert.cer, root-cert.cer-`date +F`}
mv /usr/local/nginx/houtaissl/{server-cert.cer, server-cert.cer-`date +F`}
mv /usr/local/nginx/houtaissl/{server-key.key, server-key.key-`date +F`}
cp root-cert.cer server-cert.cer server-key.key -t /usr/local/nginx/houtaissl/
