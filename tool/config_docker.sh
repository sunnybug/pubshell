#!/bin/bash

# set -e

# example
: <<'END'
curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/tool/config_docker.sh | bash
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
    tempfile="$script_path/xproxy.sh"
    if [ ! -f "$tempfile" ]; then
        tempfile=$(mktemp)
        curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/tool/xproxy.sh -o "$tempfile"
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

docker_root_mirror() {
    local conf="/etc/docker/daemon.json"
    # 如果有配置镜像就不配置了
    if grep -q "registry-mirrors" "${conf}"; then
        echo "registry-mirrors 已经正确配置，无需修改"
        return
    fi

    if [ -f "$conf" ]; then
        mv "$conf" "${conf}.bak.$(date +"%Y%m%d%H%M%S")"
        g_Change=true
    fi

    cat <<EOF > "$conf"
{
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "http://hub-mirror.c.163.com",
        "https://docker.mirrors.ustc.edu.cn/",
        "https://yxzrazem.mirror.aliyuncs.com"
    ]
}
EOF
}

docker_root_proxy() {
    echo '未实现root docker，暂不支持'
    exit 1
}

docker_rootless_proxy() {
    echo '[...]docker_rootless_proxy....'
    local proxy_conf=~/.config/systemd/user/docker.service.d/proxy.conf

    if curl -IsL "$g_my_proxy" --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        if [ -f "$proxy_conf" ]; then
            if grep -q "$g_my_proxy" "$proxy_conf"; then
                echo "HTTP_PROXY已配置:$myproxy，无需修改"
                return
            fi
        fi
        mkdir -p ~/.config/systemd/user/docker.service.d
        cat <<EOF > "$proxy_conf"
[Service]
Environment="http_proxy=$g_my_proxy"
Environment="https_proxy=$g_my_proxy"
Environment="no_proxy=*.aliyuncs.com,*.tencentyun.com,*.cn,*.zentao.net,192.168.1.185,*.aliyuncs.com"
EOF

        echo "[SUC]docker_rootless_proxy, use: $g_my_proxy"
        echo "create suc: $proxy_conf"
        g_Change=true
    else
        echo "proxy not found"
    fi
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

docker_rootless_repo() {
    echo '[...]docker_rootless_repo....'
    local ret=0
    local daemon_cfg=~/.config/docker/daemon.json
    if [ ! -f "$daemon_cfg" ]; then
        mkdir -p ~/.config/docker
        touch "$daemon_cfg"
    fi

    # jq无法正常处理-符号，所以改为python
    local insecure_registries=$(python -c "import json; data = json.load(open('$daemon_cfg')); print(data['insecure-registries'])")

    if echo "$insecure_registries" | grep -q '192.168.1.185:5000'; then
        echo "insecure-registries 已经正确配置，无需修改"
        return
    fi

    # insecure-registries
    jq -s '.[0] + {"insecure-registries": ["192.168.1.185:5000"]}' "$daemon_cfg" > tmp.json && mv tmp.json "$daemon_cfg"
    g_Change=true

    echo '[SUC]docker_rootless_repo'
}

auto_config_docker() {
    # 检查是否存在docker命令
    if ! [ -x "$(command -v docker)" ]; then
        return
    fi

    auto_load_xproxy

    # 如果docker info返回中包含rootless
    if docker info | grep -q "rootless"; then
        docker_rootless_proxy
        docker_rootless_repo
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