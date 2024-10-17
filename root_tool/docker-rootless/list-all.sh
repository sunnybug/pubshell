#!/bin/bash

list_container() {
    # 遍历 /home 目录下的所有子目录
    for dir in /home/*; do
        # 检查是否是目录
        if [ -d "$dir" ]; then
            # 获取目录名（用户名）
            user=$(basename "$dir")
            
            # 检查用户是否存在
            if id "$user" &>/dev/null; then

                if [ -f "$dir/bin/docker" ]; then
                    echo "===========用户 $user 开启的容器："
                    su $user -c "$dir/bin/docker ps -a"
                fi
            else
                echo "用户 $user 不存在，跳过..."
            fi
        fi
    done
}

list_container