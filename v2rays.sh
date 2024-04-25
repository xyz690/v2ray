#!/bin/bash

#定义操作变量, 0为否, 1为是
HELP=0

REMOVE=0

#######get params#########
while [[ $# > 0 ]];do
    key="$1"
    case $key in
        --remove)
        REMOVE=1
        ;;
        -h|--help)
        HELP=1
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

remove(){
    bash <(curl -s -L https://git.io/v2ray-uninstall.sh)
}

help(){
    echo "bash v2ray.sh [-h|--help] [--remove]"
    echo "  -h, --help           查看帮助"
    echo "      --remove         卸载V2Ray"
    echo "                       默认进行V2Ray安装"
    return 0
}

main() {

    [[ ${HELP} == 1 ]] && help && return

    [[ ${REMOVE} == 1 ]] && remove && return

    bash <(curl -s -L https://git.io/v2ray-setup.sh)
}

main