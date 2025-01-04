#!/bin/bash
echo off
# 国内不允许直接下载xproxy.sh，所以将xproxy.sh代码复制到当前脚本中
# set -e

# example
: <<'END'
curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/net/docker_net.sh | bash
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/net/docker_net.sh | bash
END

g_API_PORT=0
g_Change=false
g_use_proxy="n"
g_my_proxy=""

# 检查 DockerHub 连接性
check_dockerhub() {
    local response=$(curl -fsSL --connect-timeout 2 --max-time 2 -w "%{http_code}" -o /dev/null https://hub.docker.com)
    if [ "$response" -eq 200 ]; then
        echo 'y'
    else
        echo 'n'
    fi
}

# 检查是否需要代理
check_gfw() {
    local gfw_need_proxy="n"
    echo "[...]check_gfw"

    local gfw_dockerhub_ok=$(check_dockerhub | tail -n1)

    # 打印结果
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

# 检测代理
detect_proxy() {
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

    # save to file
    if [ -d ~/.myshell ]; then
        echo $g_my_proxy >~/.myshell/.proxy
    fi
}


# 通用的代理配置函数
configure_docker_proxy() {
    if [ "$g_use_proxy" = "n" ]; then
        echo "无需使用proxy"
        return
    fi

    local proxy_conf="$1"
    local conf_dir=$(dirname "$1")

    # 检查代理是否可用
    if ! curl -IsL "$g_my_proxy" --connect-timeout 2 --max-time 2 | grep "400 Bad Request" >/dev/null; then
        echo "proxy not found"
        return
    fi

    # 检查是否已配置
    # if [ -f "$proxy_conf" ] && grep -q "$g_my_proxy" "$proxy_conf"; then
    #     echo "HTTP_PROXY已配置:$g_my_proxy，无需修改"
    #     return
    # fi

    # 创建配置目录
    mkdir -p "$conf_dir"

    # 创建配置文件
    cat <<EOF >"$proxy_conf"
[Service]
Environment="http_proxy=$g_my_proxy"
Environment="https_proxy=$g_my_proxy"
Environment="no_proxy=*.aliyuncs.com,*.tencentyun.com,*.cn,*.zentao.net,gitclone.com,gitee.com,127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mirrors.tencent.com,mirrors.aliyun.com,sourceware.org"
EOF

    echo "[SUC]create suc: $proxy_conf"
    g_Change=true
}

# root模式的代理配置
docker_root_proxy() {
    configure_docker_proxy "/etc/systemd/system/docker.service.d/proxy.conf"
}

# rootless模式的代理配置
docker_rootless_proxy() {
    configure_docker_proxy "~/.config/systemd/user/docker.service.d/proxy.conf"
}

auto_config_docker() {
    # 检查是否存在docker命令
    if ! [ -x "$(command -v docker)" ]; then
        return
    fi

    detect_proxy

    # 如果docker info返回中包含rootless
    if docker info | grep -q "rootless"; then
        docker_rootless_proxy

        if [ "$g_Change" = true ]; then
            systemctl --user daemon-reload && systemctl --user restart docker
        else
            echo "配置无修改"
        fi
    else
        docker_root_proxy
    fi
}

auto_config_docker
