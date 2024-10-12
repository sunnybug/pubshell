#!/bin/bash

# set -e

# example
: <<'END'
curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/tool/docker_mirror.sh | bash
END

g_API_PORT=0

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


docker_root_mirror(){
    conf="/etc/docker/daemon.json"
    # 如果有配置镜像就不配置了
    if grep -q "registry-mirrors" ${conf}; then
        echo "registry-mirrors already exists, skip"
        return
    fi
    
    if [ -f $conf ]; then
        mv $conf ${conf}.bak.$(date +"%Y%m%d%H%M%S")
    fi
    
cat <<EOF > $conf
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

docker_root_proxy(){
    echo '未实现root docker，暂不支持'
    exit 1
}

docker_rootless_proxy(){
    echo '[...]docker_rootless_proxy....'
    proxy_conf=~/.config/systemd/user/docker.service.d/proxy.conf
    
    if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        if [ -f $proxy_conf ]; then
            mv $proxy_conf ${proxy_conf}.bak.$(date +"%Y%m%d%H%M%S")
        fi
        mkdir -p ~/.config/systemd/user/docker.service.d
        cat <<EOF > $proxy_conf
[Service]
Environment="HTTP_PROXY=http://192.168.1.199:10816/"
Environment="HTTPS_PROXY=http://192.168.1.199:10816/"
Environment="NO_PROXY=*.aliyuncs.com,*.tencentyun.com,*.cn,*.zentao.net,192.168.1.185"
EOF

    echo '[SUC]docker_rootless_proxy'
    echo "create suc: $proxy_conf"
    fi
}

docker_rootless_api(){
    echo '[...]docker_rootless_api....'
    # docker api
    # 如果daemon.json中不存在hosts，则添加
    daemon_cfg=~/.config/docker/daemon.json
    if ! jq -e '.hosts' $daemon_cfg > /dev/null; then
        USER_ID=$(id -u)
        PORT=$((USER_ID + 1000))
        find_available_port $PORT
        result=$?
        if [ $result -eq 1 ]; then
            PORT=$g_API_PORT
            echo "docker API 端口:$PORT"
            
            # write to daemon.json
            jq -s --arg USER_ID "$USER_ID" --arg PORT "$PORT" '
                .[0] + 
                {"hosts": ["unix:///run/user/\($USER_ID)/docker.sock", "tcp://0.0.0.0:\($PORT)"]}
            ' $daemon_cfg > tmp.json && mv tmp.json $daemon_cfg
            
            #write to myapi.conf
            api_conf=~/.config/systemd/user/docker.service.d/myapi.conf
            touch $api_conf
            cat <<EOF > $api_conf
    [Service]
    Environment=DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="-p 0.0.0.0:$PORT:$PORT/tcp"
EOF
        else
            echo "docker API 找不到可用端口"
        fi
    else
        echo "$daemon_cfg中已经存在hosts，无需配置"
    fi
    echo '[SUC]docker_rootless_api'
}

docker_rootless_repo(){
    echo '[...]docker_rootless_repo....'
    ret=0
    daemon_cfg=~/.config/docker/daemon.json
    if [ ! -e "$daemon_cfg" ]; then
        mkdir -p ~/.config/docker
        touch $daemon_cfg
    fi    
    # insecure-registries
    jq -s '.[0] + {"insecure-registries": ["192.168.1.185:5000"]}' $daemon_cfg >  tmp.json && mv tmp.json $daemon_cfg
    
    echo '[SUC]docker_rootless_repo'
}

auto_docker_mirror(){
    # 检查是否存在docker命令
    if ! [ -x "$(command -v docker)" ]; then
        return
    fi

    # 如果docker info返回中包含rootless
    if docker info | grep -q "rootless"; then
        docker_rootless_proxy
        docker_rootless_repo
        docker_rootless_api
    else
        docker_root_proxy
    fi

    echo "配置生效需要手动执行"
    echo "systemctl --user daemon-reload && systemctl --user restart docker"
    
}

auto_docker_mirror