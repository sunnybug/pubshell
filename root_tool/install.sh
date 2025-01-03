#!/bin/bash

set -e

# deb http://mirrors.aliyun.com/debian/ bullseye main contrib non-free
# deb http://mirrors.aliyun.com/debian/ bullseye-updates main contrib non-free
# deb http://mirrors.aliyun.com/debian-security bullseye-security main contrib non-free

# deb http://mirrors.aliyun.com/debian/ testing main contrib non-free
# deb http://mirrors.aliyun.com/debian/ testing-updates main contrib non-free
# deb http://mirrors.aliyun.com/debian-security testing-security main contrib non-free

# # llvm-15
# # deb https://mirrors.tuna.tsinghua.edu.cn/llvm-apt/bullseye/ llvm-toolchain-bullseye-15 main

# # 腾讯云内网
# # mirrors.tencentyun.com


##############################################
# config
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR
if [ ! -d "$SCRIPT_DIR/files" ]; then
    # 从webinstall.sh触发时，往上走1级
    cd ..
    SCRIPT_DIR=$(pwd)
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    if [ ! -d "$SCRIPT_DIR/files" ]; then
        echo "Error: Could not find files directory"
        exit 1
    fi
    
fi

###############################################
# function
# 定义函数，用于询问用户
function ask() {
    read -p "$1[y/n]" answer < /dev/stdin

    # 判断用户的输入，将其转换为小写字母并返回
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "y"
    else
        echo "n"
    fi
}

##############################################
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

function set_ssh(){
    sed -i '/^PubkeyAcceptedAlgorithms/d;$aPubkeyAcceptedAlgorithms +ssh-rsa' /etc/ssh/sshd_config
    sed -i '/^PermitRootLogin/d;$aPermitRootLogin yes' /etc/ssh/sshd_config
    sed -i 's|#MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config
    sed -i 's|MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config
}

function InstallTools_Debian() {
    echo "install tools for Debian"
    
    if [ "$(sudo -n uptime 2>&1 | grep -c "load")" -gt 0 ]; then
        echo "you have sudo. everything is ok"
    else
        echo "Please install sudo OR use sudo OR switch to root"
        exit 1
    fi
    
    set_ssh
    echo "复制配置文件....."
    cp -rTf $SCRIPT_DIR/files/etc_debian11/ /etc
    
    echo "检查域名：mirrors.tencentyun.com是否可用....."
    if [ "$(ping -c 1 mirrors.tencentyun.com | grep -c "1 received")" -gt 0 ]; then
        echo "mirrors.tencentyun.com is ok"
        sed -i "s/mirrors.aliyun.com/mirrors.tencentyun.com/g" /etc/apt/sources.list
    fi
    
    echo "install apt-fast......."
    apt update
    apt install --no-install-recommends -y debian-keyring gnupg
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1E2824A7F22B44BD 1EE2FF37CA8DA16B
    apt update
    apt-get install --no-install-recommends -y apt-fast sudo
    alias apt=apt-fast
    
    echo "install python......."
    apt install --no-install-recommends -y python3-full python3-autopep8 python3-wheel python3-pip
    sudo unlink /usr/bin/python ; sudo link /usr/bin/python3 /usr/bin/python
    
    apt install default-mysql-client  -y
    
    if [ "$is_cpp" = "y" ]; then
        echo "install tools of C++......."
        apt install --no-install-recommends -y gcc-12 gdb cgdb make cmake ninja-build build-essential linux-perf elfutils
        ##########################################
        # llvm
        # https://apt.llvm.org/
        gpg --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421
        gpg --armor --export 15CF4D18AF4F7421 | apt-key add -
        
        # llvm-15
        # grep -qxF 'deb http://mirrors.tuna.tsinghua.edu.cn/llvm-apt/bullseye/ llvm-toolchain-bullseye-15 main' /etc/apt/sources.list || echo 'deb http://mirrors.tuna.tsinghua.edu.cn/llvm-apt/bullseye/ llvm-toolchain-bullseye-15 main' >> /etc/apt/sources.list
        # apt update
        # apt install -y llvm-15
        # unlink /usr/bin/clang               ; link /usr/bin/clang-15 /usr/bin/clang
        # unlink /usr/bin/clang++             ; link /usr/bin/clang++-15 /usr/bin/clang++
        # unlink /usr/bin/clang-format        ; link /usr/bin/clang-format-15 /usr/bin/clang-format
        # unlink /usr/bin/clang-tidy          ; link /usr/bin/clang-tidy-15 /usr/bin/clang-tidy
        
        # llvm-18
        grep -qxF 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main' /etc/apt/sources.list || sudo echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main' >> /etc/apt/sources.list
        sudo apt update
        sudo apt remove -y llvm-16 clang-16 clang-format-16 clang-tidy-16 clang-tools-16 libc++-16-dev libc++abi-16-dev
        sudo apt install -y llvm-18 clang-18 clang-format-18 clang-tidy-18 clang-tools-18 libc++-18-dev libc++abi-18-dev
        sudo unlink /usr/bin/clang               ; link /usr/bin/clang-18 /usr/bin/clang
        sudo unlink /usr/bin/clang++             ; link /usr/bin/clang++-18 /usr/bin/clang++
        sudo unlink /usr/bin/clang-format        ; link /usr/bin/clang-format-18 /usr/bin/clang-format
        sudo unlink /usr/bin/clang-tidy          ; link /usr/bin/clang-tidy-18 /usr/bin/clang-tidy
    fi
    
    echo "install other......."
    apt install --no-install-recommends -y locales subversion git curl man aria2 gpg-agent rsync zip apt-file zsh sudo iptables p7zip-full psmisc htop ssh lua5.4
    
    # 使用sudo无法找到ulimit
    ulimit -c unlimited # coredump size
    # 检查对/proc/sys/kernel/core_pattern是否可写
    if [ -w /proc/sys/kernel/core_pattern ]; then
        sudo echo 'core.%e.%s.%t.dmp' > /proc/sys/kernel/core_pattern
    fi
    
    # locale
    sudo locale-gen en_US.UTF-8
    export LANG=en_US.UTF-8
    # 24小时
    echo "" >> /etc/default/locale && echo "LC_TIME=en_US.UTF-8" >> /etc/default/locale
    
    if [ "$is_github520" = "y" ]; then
        echo "add GitHub520"
        crontab -l > conf && echo "* 1 * * * sed -i \"/# GitHub520 Host Start/Q" /etc/hosts \&\& curl https://raw.hellogithub.com/hosts >> /etc/hosts\" >> conf && crontab conf && rm -f conf
    fi
    
    if [ "$is_china" = "y" ]; then
        # 时区
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    fi
    
    if [ "$is_docker" = "y" ]; then
        echo "install docker......."
        # docker
        sudo curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-ce.gpg
        source /etc/os-release
        sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list
        sudo apt update
        sudo apt install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi
}

##############################################
function InstallToolForDev()
{
    if [ -x /usr/bin/apt ] && grep -q "NAME.*Debian" /etc/os-release; then
        is_cpp=$(ask "Need C++?")
        is_docker=$(ask "Need Docker?")
        is_china="y"
        is_github520="n"
        InstallTools_Debian
    else
        echo "Current OS is not Debian"
    fi
}

function InstallToolForCppServer()
{
    if [ -x /usr/bin/apt ] && grep -q "NAME.*Debian" /etc/os-release; then
        is_cpp="y"
        is_docker="y"
        InstallTools_Debian
    else
        echo "Current OS is not Debian"
    fi
}

case "$1" in
    "--cppserver")
        InstallToolForCppServer
    ;;
    "--dev")
        InstallToolForDev
    ;;
    *)
        echo "Usage: $0 --cppserver|--dev"
        exit 1
esac

echo '=== install tools suc ==='
exit 0
