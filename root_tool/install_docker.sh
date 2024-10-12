#!/bin/bash

function install_docker()
{
    echo "install docker......."
    sudo apt update
    sudo apt install --no-install-recommends -y gpg curl
    result=$(curl -IsL https://download.docker.com/linux/debian/gpg --connect-timeout 2 --max-time 2)
    # 如果result中不含KEY则认为失败
    if [[ $result != *"KEY"* ]]; then
        echo "可能需要开代理，访问失败:https://download.docker.com/linux/debian/gpg"
        return 1
    fi
    
    echo $result | gpg --dearmor > /usr/share/keyrings/docker-ce.gpg
    source /etc/os-release
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list
    sudo apt install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

install_docker