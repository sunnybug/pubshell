#!/bin/bash

######################################################
# 错误处理函数
handle_error() {
    echo "错误: $1"
    echo "示例: --gcc_ver 14 --image_ver 192.168.1.185:5000/devgcc14:1016"
    exit 1
}

# 使用 getopt 解析命令行参数
parse_arguments() {
    OPTIONS=$(getopt -o '' --long gcc_ver:,image_ver: -- "$@") || handle_error "参数解析失败"
    eval set -- "$OPTIONS"

    # 初始化变量
    gcc_ver=""
    image_ver=""

    # 处理参数
    while true; do
        case "$1" in
            --gcc_ver) gcc_ver="$2"; shift 2 ;;
            --image_ver) image_ver="$2"; shift 2 ;;
            --) shift; break ;;
            *) handle_error "未知选项: $1" ;;
        esac
    done

    # 检查参数是否为空
    [ -z "$gcc_ver" ] && handle_error "--gcc_ver 参数未给出。"
    [ -z "$image_ver" ] && handle_error "--image_ver 参数未给出。"

    echo "gcc_ver: $gcc_ver"
    echo "image_ver: $image_ver"
}

# 构建镜像
build_image() {
    echo "构建镜像: $image_ver"
    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)
    pushd "$SCRIPT_DIR" > /dev/null
    
    # 构建指定版本的镜像
    docker build . -t "$image_ver" --build-arg gcc_ver="$gcc_ver"
    if [ $? -ne 0 ]; then
        handle_error "Docker build 失败。"
    fi

    # 标记为 latest 镜像
    docker tag "$image_ver" "${image_ver%:*}:latest"
    
    popd > /dev/null
}

# 主程序
parse_arguments "$@"
build_image

# 输出手动执行的推送命令
echo "手动执行:"
echo "docker push $image_ver"
echo "docker push ${image_ver%:*}:latest"
######################################################