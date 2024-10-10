C++开发用的镜像

## 按需配置.env

## 镜像构建
```shell
docker build -t gs:gcc14.0924 .
```

docker compose stop && docker compose rm -f && docker build -t mydev:gcc14.0924 . && docker compose up -d && docker exec -it mydev14 /usr/bin/zsh -c 'cd /home/xushuwei; exec /usr/bin/zsh'


## 宿主机准备
以rootless模式运行docker 
参考文档：https://gitee.com/sunnybug/pubshell/blob/main/root_tool/docker-rootless/readme.md

## 启动容器
./recreate.sh .env

## 进入容器
./enter.sh

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