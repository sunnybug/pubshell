#!/bin/bash

function install_root_docker(){
    echo "[...]install_root_docker......."

    curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-ce.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] http://mirrors.tencentyun.com/docker-ce/linux/debian $(lsb_release -sc) stable" > /etc/apt/sources.list.d/docker.list
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "[SUC]install_root_docker"
}

install_root_docker

