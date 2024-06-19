C++开发用的镜像

## 镜像构建
```shell
docker build -t mydev:gcc12.2 .  --progress=plain
```

docker pull registry.cn-hangzhou.aliyuncs.com/vigoo_pub/mydev:3.2

## 宿主机准备
1. 以rootless模式运行docker 
    参考文档：https://gitee.com/sunnybug/pubshell/blob/main/tools/docker-rootless/readme.md

## 镜像初始化
```shell
# 参数，无需落盘
export mydev_name=mydev12
export mydev_home=~/mydev12_home
export mydev_sshport=4012
export mydev_ver=gcc12.2
# 命令
docker stop $mydev_name && docker remove $mydev_name
docker run -v $mydev_home:/root -p $mydev_sshport:22 --hostname $mydev_name\_docker -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent -itd --name $mydev_name mydev:$mydev_ver
mkdir -p $mydev_home/.ssh
cp ~/.ssh/authorized_keys $mydev_home/.ssh/authorized_keys
docker exec -it $mydev_name /bin/bash -c 'chown root:root ~/.ssh/authorized_keys'

```

## 本地交互式进入镜像
```shell
docker exec -it mydev12 /usr/bin/zsh 
```

## 远程SSH进入镜像
方便vscode调试，证书同宿主机
```shell
ssh -p 端口 root@IP
```