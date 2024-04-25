#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"
# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e " 
	哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

echo "安装JQ:${cmd} install -y jq"
$cmd install -y jq

# 安装Warp普通用户
install_warp_socks() {
    echo -e "${green}开始安装 wireproxy，让 WARP 在本地创建一个 socks5 代理!${none}\n"
    wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && ( echo "2" && echo "13" && echo "40000" && echo "1" ) | bash menu.sh
    if [ $? -eq 0 ]; then
        echo "Download succeed."
    else
        echo "Download failed. Won't install."
        exit 1
    fi
}   

#wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh

# 输入 原来的 V2ray配置文件位置
# /etc/v2ray/config.json
# /usr/local/x-ui/bin/config.json

edit_v2ray_config() {
    configPath=""
    if [[ -f "/etc/v2ray/config.json" ]]; then
        echo "File /etc/v2ray/config.json exists."
        configPath="/etc/v2ray/config.json"
    elif [[ -f "/usr/local/x-ui/bin/config.json" ]]; then
        configPath="/usr/local/x-ui/bin/config.json"
    else
        read -p "$(echo -e "(请输入V2ray配置文件路径: ")" configPath
    fi

    # 删除原来JSON文件 // 注释
    cat $configPath | sed 's|^\s*//.*||' >temp.json

    config=`cat temp.json`

    # 操作json
    echo -e "${green}修改代理配置,使得ChatGPT流量走Warp.${none}\n"

    target_string="geosite:openai"
    main_string=`cat temp.json| jq ".routing.rules"`

    if echo "$main_string" | grep -q "$target_string"; then
        echo "V2ray 已经配置ChatGPT分流策略."
        exit 1
    else
        echo -e "${green}原配置:${none}\n"
        echo "$config"
        echo "开始添加ChatGPT分流策略."
        echo "$config" | jq '.routing.rules = [{
                "type": "field",
                "outboundTag": "warp-IPv4",
                "domain": [
                    "geosite:openai",
                    "ip.gs"
                ]
            }] + .routing.rules' | jq '.outbounds[1:1] = [{
                "protocol": "socks",
                "settings": {
                    "servers": [
                        {
                            "address": "127.0.0.1",
                            "port": 40000
                        }
                    ]
                },
                "tag": "warp-IPv4"
            }] + .outbounds[1:1]' > $configPath

        echo -e "${green}修改后的配置:${none}\n"
        echo $(cat temp.json)

        echo -e "${green}修改成功! 执行warp查看信息.${none}\n"
    fi

}

restart() {
    v2ray restart || echo -e "${red}ChatGPT解锁完成! 请手动重启V2ray或者Xray.${none}\n"
}




main() {
    # 如果安装过了 执行warp 如果没安装过install_warp_socks
    echo "0" | warp || install_warp_socks

    status_code=$(curl -Is --socks5 127.0.0.1:40000 http://www.google.com | head -n 1 | cut -d' ' -f2)
    if [ $status_code -eq 200 ]; then
        echo "socks 代理开启成功"
    else
        echo "socks 代理开启失败,该脚本得更新了"
        exit 1
    fi

    edit_v2ray_config
    restart
    echo -e "使用代理后, ${red}浏览器访问 https://ip.gs/ 显示 Cloudflare IP 则成功!!!${none}\n"
}

main