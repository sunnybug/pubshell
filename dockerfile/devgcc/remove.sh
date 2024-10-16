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


# 主程序入口
main() {
    local env_dir="$1"
    local env_file="$env_dir/.env"

    validate_args "$env_dir"

    SCRIPT_DIR=$(cd $(dirname ${env_file}); pwd)
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" --env-file=$env_file rm -sf

}

# 脚本入口
main "$1"
