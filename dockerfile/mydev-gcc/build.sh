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

# 由于镜像中需要安装docker，所以需要开proxy

# 构建镜像
echo "IMAGE_VER:$IMAGE_VER"
docker build . -t $IMAGE_VER --build-arg GCC_VER=$GCC_VER --build-arg INSTALL_DOCKER=$INSTALL_DOCKER --no-cache
if [ $? -ne 0 ]; then
    echo "Error: Docker build failed."
    exit 1
fi

# 如果输入y，则push镜像
# read -p "是否push镜像 $IMAGE_VER[y/n]" answer < /dev/stdin
# if [[ "$answer" =~ ^[Yy]$ ]]; then
#     docker push $IMAGE_VER
# fi

