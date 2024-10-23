#!/bin/bash

check_ssh_config(){
    # 如果环境变量$SSH_AUTH_SOCK不存在或者指向的路径不存在，则报错
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "[ERR]环境变量\$SSH_AUTH_SOCK没有设置。可能Mobxterm的agent转发未开"
    else
        # 检查$SSH_AUTH_SOCK指向的路径是否存在
        if [ ! -e "$SSH_AUTH_SOCK" ]; then
            echo "[ERR]\$SSH_AUTH_SOCK指向的路径'$SSH_AUTH_SOCK'不存在。"
        else
            echo "[SUC]环境变量\$SSH_AUTH_SOCK已正确设置并指向存在的路径。"
        fi
    fi
}

init_ssh_config(){
    echo "add ssh-rsa to ~/.ssh/config"
    if [ ! -f ~/.ssh/config ]; then
        echo "new ~/.ssh/config"
        mkdir -p ~/.ssh
        touch ~/.ssh/config  # 如果文件不存在，则创建一个新的文件
    fi
    
    # 检查是否已经存在所需的配置，如果不存在则新增配置
    if ! grep -q "HostKeyAlgorithms +ssh-rsa" ~/.ssh/config; then
        echo "HostKeyAlgorithms +ssh-rsa" >> ~/.ssh/config
    fi
    
    if ! grep -q "PubkeyAcceptedKeyTypes +ssh-rsa" ~/.ssh/config; then
        echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> ~/.ssh/config
    fi

    # 如果有root权限
    if [ "$(id -u)" = "0" ]; then
        sed -i 's|\(^#\)\?MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config
        # sed -i 's/\(^#\)\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        echo '[SUC]root权限，已设置ssh_config'
    else
        echo "[SUC]非root"
    fi
}
init_ssh_config
check_ssh_config