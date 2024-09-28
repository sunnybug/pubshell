#!/bin/bash

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