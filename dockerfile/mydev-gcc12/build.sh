#!/bin/bash

if [ -z "$1" ]; then
    echo "错误：缺少参数，请提供 .env 文件路径。"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "错误：文件 '$1' 不存在。"
    exit 1
fi

source $1

# 构建镜像
docker build . -t $IMAGE_VER --build-arg GCC_VER=$GCC_VER
if [ $? -ne 0 ]; then
    echo "Error: Docker build failed."
    exit 1
fi