#!/bin/bash

# example
: <<'END'
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/net/debian_mirror.sh | bash
END

# Check if sudo exists and set command prefix accordingly
if command -v sudo >/dev/null 2>&1; then
    cmd_prefix="sudo"
else
    cmd_prefix=""
fi

function _replace_debian_sources() {
    # 如果存在/etc/apt/sources.list，则备份
    if [ -f /etc/apt/sources.list ]; then
        # 将sources.list中的deb.debian.org替换为mirrors.aliyun.com
        $cmd_prefix sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
        $cmd_prefix sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
        # 注释ftp.debian.org这一行
        $cmd_prefix sed -i '/ftp.debian.org/s/^/#/' /etc/apt/sources.list

        cat /etc/apt/sources.list
    fi

    # 如果存在/etc/apt/sources.list.d/debian.sources，则备份
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then
        $cmd_prefix cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak

        # 将debian.sources中的deb.debian.org替换为mirrors.aliyun.com
        $cmd_prefix sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list.d/debian.sources
        $cmd_prefix sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list.d/debian.sources
        # 注释ftp.debian.org这一行
        $cmd_prefix sed -i '/ftp.debian.org/s/^/#/' /etc/apt/sources.list.d/debian.sources

        cat /etc/apt/sources.list.d/debian.sources
    fi
}

function _replace_ubuntu_sources() {
    local UBUNTU_CODENAME=$(lsb_release -cs)

    $cmd_prefix tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null <<EOF
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
else
    echo "Current OS is not Debian or Ubuntu"
    exit 1
fi

$cmd_prefix apt update