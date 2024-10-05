#!/bin/bash
set -e

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
    echo 'docker_rootless_proxy......'
    proxy_conf=~/.config/systemd/user/docker.service.d/proxy.conf
    
    if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        if [ -f $proxy_conf ]; then
            # 如果旧文件中已存在192.168.1.199，则跳过
            if grep -q "192.168.1.199" $proxy_conf; then
                echo "${proxy_conf} already exists 192.168.1.199, skip"
                return
            fi
            mv $proxy_conf ${proxy_conf}.bak.$(date +"%Y%m%d%H%M%S")
        fi
        mkdir -p ~/.config/systemd/user/docker.service.d
        cat <<EOF > $proxy_conf
[Service]
Environment="HTTP_PROXY=http://192.168.1.199:10816/"
Environment="HTTPS_PROXY=http://192.168.1.199:10816/"
Environment="NO_PROXY=*.aliyuncs.com,*.tencentyun.com,*.cn,*.zentao.net,192.168.*"
EOF
    echo "create suc: $proxy_conf"
    echo '手动执行: systemctl --user daemon-reload && systemctl --user restart docker'
    fi
}

docker_rootless_mirror(){
    echo '[...]docker_rootless_mirror....'
    daemon_cfg=~/.config/docker/daemon.json
    if [ ! -e "$daemon_cfg" ]; then
        mkdir -p ~/.config/docker
        touch $daemon_cfg
    fi    
    # insecure-registries
    jq -s '.[0] + {"insecure-registries": "192.168.1.185:5000"}' $daemon_cfg >  tmp.json && mv tmp.json $daemon_cfg
    echo '[SUC]docker_rootless_mirror'
}

auto_docker_mirror(){
    # 检查是否存在docker命令
    if ! [ -x "$(command -v docker)" ]; then
        return
    fi

    # 如果docker info返回中包含rootless
    if docker info | grep -q "rootless"; then
        docker_rootless_proxy
        docker_rootless_mirror
    else
        docker_root_proxy
    fi
    
}

auto_docker_mirror