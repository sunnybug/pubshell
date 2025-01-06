#/bin/bash
g_use_proxy="n"

check_dockerhub() {
    local response=$(curl -fsSL --connect-timeout 2 --max-time 2 -w "%{http_code}"  -o /dev/null https://hub.docker.com)
    if [ "$response" -eq 200 ]; then
        echo 'y'
            return
    else
        echo 'n'
    fi
}

check_github() {
    local response=$(curl -fsSL --connect-timeout 2 --max-time 2 -o /dev/null -w "%{http_code}"  -o /dev/null https://github.com/login)
    if [ "$response" -eq 200 ]; then
        echo 'y'
        return
    fi

    echo 'n'
}

check_gfw() {
    gfw_need_proxy="n"
    echo "[...]check_gfw"

    tmpfile=$(mktemp)

    gfw_github_ok=$(check_github)
    gfw_dockerhub_ok=$(check_dockerhub | tail -n1)

    # 打印结果
    if [ "$gfw_github_ok" = "y" ]; then
        echo -e "github.com:   \033[32m可连接\033[0m"
    else
        echo -e "github.com:   \033[31m不可连接\033[0m"
        gfw_need_proxy="y"
    fi
    if [ "$gfw_dockerhub_ok" = "y" ]; then
        echo -e "dockerhub:   \033[32m可连接\033[0m"
    else
        echo -e "dockerhub:   \033[31m不可连接\033[0m"
        gfw_need_proxy="y"
    fi
    if [ "$gfw_need_proxy" = "y" ]; then
        echo -e "\033[31m需要代理\033[0m"
    else
        echo -e "\033[32m不需要代理\033[0m"
    fi
    echo "[SUC]check_gfw"

    if [ "$gfw_need_proxy" = "y" ]; then
        g_use_proxy="y"
    fi
}

xdetectproxy() {
    echo 'check proxy(如果卡太久，就Ctrl+c，再运行一次)...'
    check_gfw

    echo 'check 192.168.1.199:10816'
    if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" >/dev/null; then
        g_my_proxy='http://192.168.1.199:10816'
        g_use_proxy="y"
    elif curl -IsL http://127.0.0.1:10811 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" >/dev/null; then
        g_my_proxy='http://127.0.0.1:10811'
        g_use_proxy="y"
    fi

    # 如果当前用户是root
    # if [ "$(whoami)" = "root" ]; then
    #     echo "add GitHub520"
    #     sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
    # fi

    # save to file
    if [ -d ~/.myshell ]; then
        echo $g_my_proxy >~/.myshell/.proxy
    fi
}

# read file to $g_my_proxy
if [ "$1" = "--detect" ]; then
    xdetectproxy
elif [ -e ~/.myshell/.proxy ]; then
    g_my_proxy=$(cat ~/.myshell/.proxy)
else
    xdetectproxy
fi

alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
alias xopenproxy="export http_proxy='''$g_my_proxy''';export https_proxy='''$g_my_proxy''';echo \"g_my_proxy:$g_my_proxy\";"

#解决bzip2 403问题(但直接从v2ray走则正常):
#  curl -sSL https://sourceware.org -v -x http://127.0.0.1:10811
export no_proxy="gitclone.com,gitee.com,127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mirrors.tencent.com,mirrors.aliyun.com,.aliyuncs.com,.cn,sourceware.org"
