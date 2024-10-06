#!/bin/bash

CONTAINER_NAME="mydev12"
if docker ps -a | grep -qw "${CONTAINER_NAME}"; then
  echo "容器 ${CONTAINER_NAME} 已经创建。"
  docker exec -it ${CONTAINER_NAME} /bin/zsh
  exit 0
fi

IMAGE_VER=gs:gcc12
# 宿主机中用户的home目录(认为是代码和conan的默认目录)
HOST_HOME=/home/$USER
# 容器中用户的home目录在宿主机中的挂载
DOCKER_HOME=/home/$USER/mydev12_home
MY_CONAN_HOME=/home/$USER/mydev12_home/.conan2
SSH_PORT=12001
AUTHORIZED_KEYS=~/.ssh/authorized_keys
WS_PORT=12002
WSS_PORT=12003
MGR_PORT=12004
docker run \
  --name ${CONTAINER_NAME} \
  --hostname ${CONTAINER_NAME} \
  -e SSH_AUTH_SOCK=/run/ssh_agent.sock \
  -e IS_DOCKER \
  -e MY_NAME=${USER} \
  -e CONAN_HOME=${HOST_HOME}/.conan2 \
  -v ${SSH_AUTH_SOCK}:/run/ssh_agent.sock \
  -v ${HOST_HOME}/g:/${HOST_HOME}/g \
  -v ${HOST_HOME}/module:/${HOST_HOME}/module \
  -v ${HOST_HOME}/.conan2:/${HOST_HOME}/.conan2 \
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