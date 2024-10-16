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

    # 下载文件
    curl -o $dir_name/docker-compose.yml https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/devgcc/dev14/docker-compose.yml
    curl -o $dir_name/.env https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/devgcc/dev14/.env
    curl -o start.sh https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/devgcc/start.sh
    curl -o del.sh https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/devgcc/del.sh

    # 使 start.sh 脚本可执行
    chmod +x start.sh

    # 替换目录中所有文件里的字符串 "dev14" 为 $dir_name
    find . -type f -exec sed -i "s/dev14/$dir_name/g" {} \;

    echo "创建~/devgcc/$dir_name 成功，启动容器:"
    echo "cd ~/devgcc && ./start.sh $dir_name"
}

# 使用函数，传入你想要的目录名称作为参数
create_dev_environment "${args[@]}"