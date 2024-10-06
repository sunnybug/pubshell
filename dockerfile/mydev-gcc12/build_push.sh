#!/bin/bash
set -e

# 定义函数
build_and_push_image() {
    local url="$1"
    # 构建镜像
    docker build . -t $url
    if [ $? -ne 0 ]; then
        echo "Error: Docker build failed."
        return 1
    fi

    # 推送镜像
    docker push $url
    if [ $? -ne 0 ]; then
        echo "Error: Docker push failed."
        return 1
    fi
    echo "Build and push suc:$url"

    return 0
}

# 调用函数
source .env
if build_and_push_image $IMAGE_VER; then
    echo ""
else
    echo "Build and push failed."
    exit 1
fi