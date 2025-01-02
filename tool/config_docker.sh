#!/bin/bash

# set -e

# example
: <<'END'
curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/tool/config_docker.sh | bash
END

g_API_PORT=0
g_Change=false

auto_load_xproxy(){
    if [ ! -z "$g_my_proxy" ]; then
        return
    fi
    echo '[...]auto_load_xproxy...'
    # xproxy.sh
    script_path=$(dirname "$(realpath "$0")")
    tempfile="$script_path/tool/xproxy.sh"
    if [ ! -f "$tempfile" ]; then
        echo '[WRN]download xproxy.sh'
        tempfile=$(mktemp)
        curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/tool/xproxy.sh -o "$tempfile"
        if [ ! -f "$tempfile" ]; then
            echo "下载xproxy.sh失败"
            return 1
        fi
    fi
    # 检查文件是否为空
    if [ ! -s "$tempfile" ]; then
        echo "xproxy.sh文件为空"
        return 1
    fi
    # 检查文件是否包含有效的shell脚本
    if ! grep -q "^#/bin/bash" "$tempfile"; then
        echo "ERR:xproxy.sh不是有效的shell脚本:"
        cat "$tempfile"
        return 1
    fi
    source "$tempfile"
    echo '[SUC]auto_load_xproxy'
}

# 判断端口是否被占用
check_port() {
    local port=$1

    # 使用 netstat 检查端口是否被占用
    if netstat -tuln | grep -q ':'"$port"'[[:space:]]'; then
        return 1  # 端口被占用，返回 1
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

# 配置Docker镜像加速器的通用函数[国内镜像基本被封杀]
# configure_docker_mirror() {
#     local conf="$1"
#     echo '[...]配置Docker镜像加速器...'

#     # 检查是否已配置镜像
#     if grep -q "registry-mirrors" "${conf}"; then
#         echo "registry-mirrors 已经正确配置，无需修改"
#         return
#     fi

#     # 备份现有配置
#     if [ -f "$conf" ]; then
#         mv "$conf" "${conf}.bak.$(date +"%Y%m%d%H%M%S")"
#         g_Change=true
#     fi

#     # 确保配置目录存在
#     mkdir -p "$(dirname "$conf")"

#     # 写入镜像配置
#     cat <<EOF > "$conf"
# {
#     "registry-mirrors": [
#         "https://registry.docker-cn.com",
#         "https://yxzrazem.mirror.aliyuncs.com"
#     ]
# }
# EOF
#     echo "[SUC]镜像加速器配置完成: $conf"
# }

# root模式下配置镜像加速器
# docker_root_mirror() {
#     configure_docker_mirror "/etc/docker/daemon.json"
# }

# rootless模式下配置镜像加速器
# docker_rootless_mirror() {
#     configure_docker_mirror "$HOME/.config/docker/daemon.json"
# }

# 通用的代理配置函数
configure_docker_proxy() {
    if [ "$g_use_proxy" = "n" ]; then
        echo "无需使用proxy"
        return
    fi

    local proxy_conf="$1"
    local conf_dir=$(dirname "$1")

    # 检查代理是否可用
    if ! curl -IsL "$g_my_proxy" --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        echo "proxy not found"
        return
    fi

    # 检查是否已配置
    if [ -f "$proxy_conf" ] && grep -q "$g_my_proxy" "$proxy_conf"; then
        echo "HTTP_PROXY已配置:$g_my_proxy，无需修改"
        return
    fi

    # 创建配置目录
    mkdir -p "$conf_dir"

    # 创建配置文件
    cat <<EOF > "$proxy_conf"
[Service]
Environment="http_proxy=$g_my_proxy"
Environment="https_proxy=$g_my_proxy"
Environment="no_proxy=*.aliyuncs.com,*.tencentyun.com,*.cn,*.zentao.net,192.168.1.185,*.aliyuncs.com"
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
            ' "$daemon_cfg" > tmp.json && mv tmp.json "$daemon_cfg"
            g_Change=true

            # 写入myapi.conf
            local api_conf=~/.config/systemd/user/docker.service.d/myapi.conf
            touch "$api_conf"
            cat <<EOF > "$api_conf"
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

    auto_load_xproxy

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