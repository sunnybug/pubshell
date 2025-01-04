#!/bin/bash
echo off
# 国内不允许直接下载xproxy.sh，所以将xproxy.sh代码复制到当前脚本中
# set -e

# example
: <<'END'
curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/tool/config_docker.sh | bash
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

# 判断端口是否被占用
check_port() {
    local port=$1

    # 使用 netstat 检查端口是否被占用
    if netstat -tuln | grep -q ':'"$port"'[[:space:]]'; then
        return 1 # 端口被占用，返回 1
    fi
    return 0
}

# 查找可用端口
find_available_port() {
    local start_port=$1
    local max_attempts=100
    local current_port=$start_port
    local attempts=0

    while [ $attempts -lt $max_attempts ]; do
        check_port $current_port
        if [ $? -eq 0 ]; then
            g_API_PORT=$current_port
            return 1
        fi
        ((current_port++))
        ((attempts++))
    done

    echo "未能找到可用端口，已尝试 $max_attempts 次"
    return 0
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

docker_rootless_api() {
    echo '[...]docker_rootless_api....'
    local daemon_cfg=~/.config/docker/daemon.json
    local USER_ID=$(id -u)
    local PORT=$((USER_ID + 1000))

    # 获取当前的hosts配置
    local current_hosts=$(jq -r '.hosts // empty' "$daemon_cfg" 2>/dev/null)

    # 检查是否已存在特定的hosts配置
    if [[ -z "$current_hosts" ]]; then
        # 如果不存在，则查找可用端口并进行配置
        find_available_port $PORT
        local result=$?
        if [ $result -eq 1 ]; then
            PORT=$g_API_PORT
            echo "docker API 端口: $PORT"

            # 写入daemon.json
            jq -s --arg USER_ID "$USER_ID" --arg PORT "$PORT" '
                .[0] +
                {"hosts": ["unix:///run/user/\($USER_ID)/docker.sock", "tcp://127.0.0.1:\($PORT)"]}
            ' "$daemon_cfg" >tmp.json && mv tmp.json "$daemon_cfg"
            g_Change=true

            # 写入myapi.conf
            local api_conf=~/.config/systemd/user/docker.service.d/myapi.conf
            touch "$api_conf"
            cat <<EOF >"$api_conf"
[Service]
Environment=DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="-p 127.0.0.1:$PORT:$PORT/tcp"
EOF
        else
            echo "docker API 找不到可用端口"
        fi
    else
        echo "$daemon_cfg中已经存在hosts，无需配置"
        local hosts_content=$(jq -r '.hosts' "$daemon_cfg" 2>/dev/null)
        if [[ -n "$hosts_content" ]]; then
            echo "$hosts_content"
        fi
    fi
    echo '[SUC]docker_rootless_api'
}

# rootless模式下的私有仓库配置(不再使用，改用支持ssl的私有仓库)
# docker_rootless_repo() {
#     echo '[...]docker_rootless_repo....'
#     local ret=0
#     local daemon_cfg=~/.config/docker/daemon.json
#     if [ ! -f "$daemon_cfg" ]; then
#         mkdir -p ~/.config/docker
#         touch "$daemon_cfg"
#     fi

#     # jq无法正常处理-符号，所以改为python
#     local insecure_registries=$(python -c "
# import json
# import sys

# try:
#     with open('$daemon_cfg') as f:
#         data = json.load(f)
#         print(data['insecure-registries'])
# except Exception:
#     pass  # 捕获异常并不输出任何信息
# ")

#     if echo "$insecure_registries" | grep -q '192.168.1.185:5000'; then
#         echo "insecure-registries 已经正确配置，无需修改"
#         return
#     fi

#     # 如果没有安装jq，则使用python
#     if ! [ -x "$(command -v jq)" ]; then
#         echo "未安装jq"
#         return
#     fi

#     # insecure-registries
#     jq -s '.[0] + {"insecure-registries": ["192.168.1.185:5000"]}' "$daemon_cfg" > tmp.json && mv tmp.json "$daemon_cfg"
#     g_Change=true

#     echo '[SUC]docker_rootless_repo'
# }

auto_config_docker() {
    # 检查是否存在docker命令
    if ! [ -x "$(command -v docker)" ]; then
        return
    fi

    detect_proxy

    # 如果docker info返回中包含rootless
    if docker info | grep -q "rootless"; then
        docker_rootless_proxy
        # docker_rootless_repo
        docker_rootless_api

        if [ "$g_Change" = true ]; then
            systemctl --user daemon-reload && systemctl --user restart docker
        else
            echo "配置无修改"
        fi
    else
        docker_root_proxy
        # docker_root_mirror
    fi
}

auto_config_docker
