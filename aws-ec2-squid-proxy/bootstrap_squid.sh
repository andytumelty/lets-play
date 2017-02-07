#!/bin/bash
yum update -y

yum install -y squid
sed -i 's/\(http_port .*\)/\1 intercept/' /etc/squid/squid.conf
sed -i '/INSERT/a acl whitelist dstdomain "/etc/squid/whitelist.txt"\nhttp_access allow whitelist' /etc/squid/squid.conf
sed -i '/http_access allow local/d' /etc/squid/squid.conf
echo '.amazonaws.com' > /etc/squid/whitelist.txt
service squid start

chkconfig squid on
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3128
service iptables save
