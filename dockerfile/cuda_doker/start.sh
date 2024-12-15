#!/bin/bash

# 定义函数用于参数验证
function validate_args() {
    local env_dir="$1"
    local env_file="$env_dir/.env"

    if [ -z "$env_dir" ]; then
        echo "错误：缺少参数，请提供 .env 所在目录"
        exit 1
    fi

    if [ ! -f "$env_file" ]; then
        echo "错误：文件 '$env_file' 不存在。"
        exit 1
    fi
}

# 定义函数用于检查容器是否存在
function container_exists() {
    local container_name="$1"
    if docker ps -a | grep -qP "^${container_name}$|^${container_name}\s"; then
        return 0
    else
        return 1
    fi
}

# 定义函数用于创建容器
function create_container() {
    local env_file="$1"
    local container_name="$2"

    if container_exists "$container_name"; then
        echo "删除容器 $container_name"
        docker rm "$container_name" -f
        return
    fi

    echo "正在创建容器 $container_name..."
 local SCRIPT_DIR=$(cd "$(dirname "$env_file")"; pwd)
    local cmd="docker compose --env-file=\"$env_file\" -f \"$SCRIPT_DIR/docker-compose.yml\" up -d"
    echo "$cmd"
    eval "$cmd"
}

# 主程序入口
main() {
    local env_dir="$1"
    local env_file="$env_dir/.env"

    validate_args "$env_dir"
    source "$env_file"

    create_container "$env_file" "$CONTAINER_NAME"

    docker exec -it $CONTAINER_NAME bash -c 'if [ ! -d /root/.myshell ]; then curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/install/webinstall_pubshell.sh | bash; fi'

}

# 脚本入口
main "$1"