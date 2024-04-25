#!/bin/bash

echo -e "先把域名解析到当前服务器IP,然后将域名填到下面，一定一定一定要正确，不！能！出！错！ 退出请安 Ctrl + C"
read -p "(例如：demo.com或www.demo.com): " domain
echo "1
33

${domain}
Y
N
N
N" | bash <(curl -s -L https://raw.githubusercontent.com/xyz690/v2ray/master/install.sh)