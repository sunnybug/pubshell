#!/bin/bash

function _replace_debian_sources() {
    # 将sources.list中的deb.debian.org替换为mirrors.aliyun.com
    sudo sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
    sudo sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
    # 注释ftp.debian.org这一行
    sudo sed -i '/ftp.debian.org/s/^/#/' /etc/apt/sources.list

    cat /etc/apt/sources.list
}

function _replace_ubuntu_sources() {
    local UBUNTU_CODENAME=$(lsb_release -cs)

    sudo tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null <<EOF
Types: deb
URIs: http://mirrors.163.com/ubuntu/
Suites: $UBUNTU_CODENAME $UBUNTU_CODENAME-updates $UBUNTU_CODENAME-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    cat /etc/apt/sources.list.d/ubuntu.sources
}

# 必须是root
if [ "$(id -u)" != "0" ]; then
    echo "Please run as root"
    exit 1
fi

if [ -x /usr/bin/apt ] && grep -q "NAME.*Debian" /etc/os-release; then
    echo "Current OS is Debian"
    _replace_debian_sources
elif [ -x /usr/bin/apt ] && grep -q "NAME.*Ubuntu" /etc/os-release; then
    echo "Current OS is Ubuntu"
    _replace_ubuntu_sources
fi

sudo apt update