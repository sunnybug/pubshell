#!/bin/bash

function install_docker(){
    echo "[...]install_docker......."
    sudo apt update
    sudo apt install --no-install-recommends -y gpg curl
    curl -sS https://download.docker.com/linux/debian/gpg --connect-timeout 2 --max-time 2 | gpg --dearmor > /usr/share/keyrings/docker-ce.gpg
    if [ $? -ne 0 ]; then
        echo "gpg error"
        return
    fi

    echo $result | gpg --dearmor > /usr/share/keyrings/docker-ce.gpg
    source /etc/os-release
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list
    sudo apt install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "[SUC]install_docker"
}

install_docker