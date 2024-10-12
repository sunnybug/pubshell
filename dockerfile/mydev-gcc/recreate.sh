#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "错误：缺少参数，请提供 .env 文件路径。"
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "错误：文件 '$1' 不存在。"
    exit 1
fi

# 如果容器已在运行，则停止它
if docker ps -a | grep -qP "^${CONTAINER_NAME}$|^${CONTAINER_NAME}\s"; then
  echo "停止容器 ${CONTAINER_NAME} "
  docker stop ${CONTAINER_NAME}
  echo "删除容器 ${CONTAINER_NAME} "
  docker rm ${CONTAINER_NAME}
fi

source $1
docker compose --env-file=$1 up -d
echo "CONTAINER_NAME:${CONTAINER_NAME}  GCC_VER:${GCC_VER}"
docker exec -it $CONTAINER_NAME bash -c 'if [ ! -d /root/.myshell ]; then curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/webinstall_pubshell.sh | bash; fi'