#!/bin/bash

function _replace_debian_sources() {
    # 将sources.list中的deb.debian.org替换为mirrors.aliyun.com
    sudo sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
    sudo sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
    # 注释ftp.debian.org这一行
    sudo sed -i '/ftp.debian.org/s/^/#/' /etc/apt/sources.list
}

if [ -x /usr/bin/apt ] && grep -q "NAME.*Debian" /etc/os-release; then
    echo "Current OS is Debian"
    _replace_debian_sources
else
    echo "Current OS is not Debian"
    exit 1
fi