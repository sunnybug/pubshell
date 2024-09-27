C++开发用的镜像

## 按需配置.env

## 镜像构建
```shell
docker build -t mydev:gcc14.0924 .
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

## 启动容器
```shell
docker compose up -d
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