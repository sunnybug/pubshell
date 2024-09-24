C++开发用的镜像

## 镜像构建
```shell
docker build -t mydev:gcc13.0924 .
```

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

## 镜像初始化
```shell
# 参数，无需落盘
export mydev_name=mydev13
export mydev_home=~/mydev13_home
export mydev_sshport=4013
# 命令
docker stop $mydev_name && docker remove $mydev_name
docker run -v $mydev_home:/root -p $mydev_sshport:22 --hostname $mydev_name\_docker -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent -itd --name $mydev_name mydev:gcc13.0924

# 初始化ssh（可选）
mkdir -p $mydev_home/.ssh
cp ~/.ssh/authorized_keys $mydev_home/.ssh/authorized_keys
docker exec -it $mydev_name /bin/bash -c 'chown root:root ~/.ssh/authorized_keys'

# 初始化shell（可选）
docker exec -it $mydev_name bash -c 'curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/install_pubshell.sh | bash'

```

## 本地交互式进入镜像
```shell
docker exec -it mydev13 /usr/bin/zsh 
```

## 远程SSH进入镜像
方便vscode调试，证书同宿主机
```shell
ssh -p 端口 root@IP
```