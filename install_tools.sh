#!/bin/bash

###
 # @Date: 2023-04-08
 # @Description: 
 # @LastEditTime: 2023-04-08
 # @LastEditors: xushuwei
### 

##############################################
# config
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

##############################################
function InstallTools_Debian() {
# debian 11
############################
# 网络设置
# 查看网卡名
# ip link
# 配置 /etc/network/interfaces
#   auto enp3s0
#   iface enp3s0 inet static
#   address 192.168.1.185
#   netmask 255.255.255.0
#   gateway 192.168.1.1

# /etc/resolv.conf 配置 nameserver 8.8.8.8

# /etc/ssh/sshd_config 配置
#   PermitRootLogin yes 

# /etc/init.d/networking restart
# systemctl restart sshd

    echo "install tools for Debian"

    if [ "$(sudo -n uptime 2>&1 | grep -c "load")" -gt 0 ]; then
        echo "you have sudo.everything is ok"
    else
        echo "Please install sudo OR use sudo OR switch to root"
        exit 1
    fi

    echo "复制配置好的文件....."
    cp -rTf $SCRIPT_DIR/files/etc_debian11/ /etc

    echo "add GitHub520"
    crontab -l > conf && echo "* 1 * * * sed -i \"/# GitHub520 Host Start/Q" /etc/hosts \&\& curl https://raw.hellogithub.com/hosts >> /etc/hosts\" >> conf && crontab conf && rm -f conf

    echo "apt update......."
    apt update
    apt install -y debian-keyring
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B

    echo "install apt-fast......."
    apt update
    apt-get install -y apt-fast sudo
    alias apt=apt-fast

    echo "install python......."
    apt upgrade -y
    apt install -y python3-full python3-autopep8 python3-wheel python3-pip
    sudo unlink /usr/bin/python ; sudo link /usr/bin/python3 /usr/bin/python

    echo "install tools of C++......."
    apt install -y gcc-12 gdb cgdb clang-format-15 clang-tidy-15

    echo "install other......."
    apt install -y locales subversion git curl man aria2 gpg-agent ninja-build build-essential gdb rsync make zip cmake apt-file zsh sudo iptables p7zip-full psmisc htop
    sudo unlink /usr/bin/clang-format ; sudo link /usr/bin/clang-format-15 /usr/bin/clang-format
    sudo unlink /usr/bin/clang-tidy ; sudo link /usr/bin/clang-tidy-15 /usr/bin/clang-tidy

    sudo locale-gen en_US.UTF-8
    export LANG=en_US.UTF-8
    # 时区
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    # 24小时
    echo "" >> /etc/default/locale && echo "LC_TIME=en_DK.UTF-8" >> /etc/default/locale

    echo "install docker......."
    # docker
    sudo curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-ce.gpg
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $(lsb_release -sc) stable" > /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}


##############################################
if [ -x /usr/bin/apt ] && [ "$(lsb_release -d | awk '{print $2}')" = "Debian" ]; then
    InstallTools_Debian
else
    echo "Current OS is not Debian"
fi