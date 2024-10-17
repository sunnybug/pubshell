#!/bin/bash

echo 'just run once'


enable_linger_for_users() {
    # 遍历 /home 目录下的所有子目录
    for dir in /home/*; do
        # 检查是否是目录
        if [ -d "$dir" ]; then
            # 获取目录名（用户名）
            user=$(basename "$dir")
            
            # 检查用户是否存在
            if id "$user" &>/dev/null; then
                # 执行 enable-linger
                echo "为用户 $user 启用 linger..."
                sudo loginctl enable-linger "$user"
            else
                echo "用户 $user 不存在，跳过..."
            fi
        fi
    done
}


sudo apt install -y uidmap fuse-overlayfs dbus-user-session slirp4netns
enable_linger_for_users

sudo systemctl disable --now docker.service docker.socket