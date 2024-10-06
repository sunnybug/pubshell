#!/bin/bash

if [ -z "$1" ]; then
    echo "错误：缺少参数，请提供 .env 文件路径。"
    exit 1
fi
if [ -z "$2" ]; then
    echo "错误：缺少参数，请提供 容器名。"
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "错误：文件 '$1' 不存在。"
    exit 1
fi

source $1
CONTAINER_NAME=$2

if docker ps -a | grep -qw "${CONTAINER_NAME}"; then
  echo "容器 ${CONTAINER_NAME} 已存在。"
  exit 0
fi

docker run \
  --name ${CONTAINER_NAME} \
  --hostname ${CONTAINER_NAME} \
  -e SSH_AUTH_SOCK=/run/ssh_agent.sock \
  -e IS_DOCKER \
  -e MY_NAME=${USER} \
  -e CONAN_HOME=${MY_CONAN_HOME} \
  -v ${SSH_AUTH_SOCK}:/run/ssh_agent.sock \
  -v ${HOST_HOME}/g:/${HOST_HOME}/g \
  -v ${HOST_HOME}/module:/${HOST_HOME}/module \
  -v ${MY_CONAN_HOME}:/${MY_CONAN_HOME} \
  -v ${DOCKER_HOME}:/root \
  -v ${AUTHORIZED_KEYS}:/root/.ssh/authorized_keys \
  -p ${SSH_PORT}:22 \
  -p ${WS_PORT}:9521 \
  -p ${WSS_PORT}:29521 \
  -p ${MGR_PORT}:20522 \
  --tty \
  --interactive \
  ${IMAGE_VER} \
  /bin/zsh

  docker exec -it ${CONTAINER_NAME} /bin/zsh
  