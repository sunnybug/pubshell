C++开发用的镜像

## 按需配置.env

## 镜像构建
```shell
docker build -t mydev:gcc14.0924 .
```

docker compose stop && docker compose rm -f && docker build -t mydev:gcc14.0924 . && docker compose up -d && docker exec -it mydev14 /usr/bin/zsh -c 'cd /home/xushuwei; exec /usr/bin/zsh'

docker pull registry.cn-hangzhou.aliyuncs.com/vigoo_pub/mydev:3.2

## 宿主机准备
1. 以rootless模式运行docker 
    参考文档：https://gitee.com/sunnybug/pubshell/blob/main/tools/docker-rootless/readme.md
2. 准备好数据卷
```shell
   mkdir ~/mydev_home
```
3. 选择转发的ssh端口
   如 4022

## 启动容器
```shell
docker compose up -d

docker compose stop && docker compose rm -f && docker build -t mydev:gcc14.0924 . && docker compose up -d && docker exec -it mydev14 /usr/bin/zsh -c 'cd /home/xushuwei; exec /usr/bin/zsh'     


# docker run
IMAGE_VER=mydev:gcc14
CONTAINER_NAME=mydev14-m
# 宿主机中用户的home目录(认为是代码和conan的默认目录)
HOST_HOME=/home/$USER
# 容器中用户的home目录在宿主机中的挂载
DOCKER_HOME=/home/$USER/mydev14-m_home
SSH_PORT=4014
AUTHORIZED_KEYS=~/.ssh/authorized_keys
SSH_PORT=4014
WS_PORT=9524
WSS_PORT=29524
MGR_PORT=20524
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

```

# 初始化shell（可选）
docker exec -it $mydev_name bash -c 'curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/webinstall_pubshell.sh | bash'

```

## 本地交互式进入镜像
```shell
docker exec -it mydev14 /usr/bin/zsh 
```

## 远程SSH进入镜像
方便vscode调试，证书同宿主机
```shell
ssh -p 端口 root@IP
```