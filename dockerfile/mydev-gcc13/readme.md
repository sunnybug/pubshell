C++开发用的镜像

## 镜像构建
```shell
docker build -t mydev:gcc13.2 .  --progress=plain
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
docker stop mydev && docker remove mydev
docker run -v ~/mydev_home:/root -p 4022:22 --hostname mydev_docker -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent -itd --name mydev mydev:gcc13.2
docker cp ~/.ssh/authorized_keys mydev:/root/.ssh/authorized_keys
docker exec -it mydev /bin/bash -c 'chown root:root ~/.ssh/authorized_keys'

```

## 进入镜像
```shell
docker exec -it mydev /usr/bin/zsh 
```

