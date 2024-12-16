#!/bin/bash

# 接收所有传递给脚本的参数
args=("$@")

create_dev_environment() {
    local dir_name=$1

    if [ -z "$dir_name" ]; then
        echo "错误：缺少参数，请提供目录(容器）名称。"
        exit 1
    fi

    # 创建目录并进入
    mkdir -p ~/devgcc/$dir_name && cd ~/devgcc

    # 如何cd失败则退出
    if [ $? -ne 0 ]; then
        echo "创建目录失败，请检查权限或路径是否正确。"
        exit 1
    fi

    # 遍历~/devgcc下所有子目录中的.env,找到最大的PORT_BASE
    max_port_base=14
    for env_file in $(find ~/devgcc -type f -name ".env"); do
        port_base=$(grep -oP 'PORT_BASE=\K\d+' $env_file)
        if [ ! -z "$port_base" ] && [ "$port_base" -gt "$max_port_base" ]; then
            max_port_base=$port_base
        fi
    done

    # 下载文件
    curl -o $dir_name/docker-compose.yml https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/dockerfile/devgcc/dev14/docker-compose.yml
    curl -o $dir_name/.env https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/dockerfile/devgcc/dev14/.env
    curl -o start.sh https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/dockerfile/devgcc/start.sh
    curl -o remove.sh https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/dockerfile/devgcc/remove.sh
    curl -o enter.sh https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/dockerfile/devgcc/enter.sh
    curl -o create_new.sh https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/dockerfile/devgcc/create_new.sh

    # 使 start.sh 脚本可执行
    chmod +x ~/devgcc/*.sh

    # 替换目录中所有文件里的字符串 "temp_str" 为 $dir_name
    find $dir_name -type f -exec sed -i "s/temp_str/$dir_name/g" {} \;

    # 修改$dir_name/.env中的PORT_BASE
    sed -i "s/PORT_BASE=.*/PORT_BASE=$((max_port_base + 1))/" $dir_name/.env

    echo "创建~/devgcc/$dir_name 成功，启动容器:"
    echo "cd ~/devgcc && ./start.sh $dir_name"

    source $dir_name/.env
    echo "SSH_PORT: $SSH_PORT"
}

# 使用函数，传入你想要的目录名称作为参数
create_dev_environment "${args[@]}"