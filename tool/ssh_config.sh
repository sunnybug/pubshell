#!/bin/bash

check_ssh_config(){
    # 如果环境变量$SSH_AUTH_SOCK不存在或者指向的路径不存在，则报错
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "[ERR]环境变量\$SSH_AUTH_SOCK没有设置。可能时Mobxterm的转发未开"
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
        touch ~/.ssh/config  # 如果文件不存在，则创建一个新的文件
    fi
    
    # 检查是否已经存在所需的配置，如果不存在则新增配置
    if ! grep -q "HostKeyAlgorithms +ssh-rsa" ~/.ssh/config; then
        echo "HostKeyAlgorithms +ssh-rsa" >> ~/.ssh/config
    fi
    
    if ! grep -q "PubkeyAcceptedKeyTypes +ssh-rsa" ~/.ssh/config; then
        echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> ~/.ssh/config
    fi

}
init_ssh_config
check_ssh_config