#!/bin/bash

docker_root_mirror(){
    conf=/etc/docker/daemon.json
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
}#
EOF
}

docker_root_proxy(){
    
}

docker_rootless_proxy(){
    echo 'docker_rootless_proxy......'
    
    if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        mkdir -p ~/.config/systemd/user/docker.service.d
        proxy_conf=~/.config/systemd/user/docker.service.d/proxy.conf
        if [ -f $proxy_conf ]; then
            mv $proxy_conf ${proxy_conf}.bak.$(date +"%Y%m%d%H%M%S")
        fi
cat <<EOF > $proxy_conf
[Service]
Environment="HTTP_PROXY=http://192.168.1.199:10816/"
Environment="HTTPS_PROXY=http://192.168.1.199:10816/"
Environment="NO_PROXY=*.aliyuncs.com,*.tencentyun.com,*.cn,*.zentao.net"
EOF
    fi
}

docker_rootless_mirror(){
    # /.config/docker/daemon.json
}

auto_docker_mirror(){
    # 如果docker info返回中包含rootless
    if docker info | grep -q "rootless"; then
        docker_rootless_proxy
    else
        docker_root_proxy
    fi
    
}

auto_docker_mirror