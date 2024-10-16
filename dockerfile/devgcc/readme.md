C++开发用的镜像

## 傻瓜版
以容器名为dev14为例（要多个容器就创建多个目录，同时替换所有dev14关键字）：
curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/webinstall_pubshell.sh | bash
mkdir ~/devgcc14/dev14 && cd ~/devgcc14
curl -o dev14/docker-compose.yml https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/dev-gcc/dev14/docker-compose.yml
curl -o dev14/.env https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/dev-gcc/dev14/.env
curl -o start.sh https://gitee.com/sunnybug/pubshell/raw/main/dockerfile/dev-gcc/start.sh
编辑dev14/.env中的镜像版本/端口等
./start.sh dev14
将代码放在/root/下，默认配置下宿主机目录为/home/$USER/dev${gcc_ver}_home

## 按需配置.env

## 镜像构建
```shell
build/build.sh --gcc_ver 14 --image_ver 192.168.1.185:5000/dev:1016
```

docker compose stop && docker compose rm -f && docker build -t dev:gcc14.0924 . && docker compose up -d && docker exec -it dev /usr/bin/zsh -c 'cd /home/xushuwei; exec /usr/bin/zsh'


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
docker exec -it dev /usr/bin/zsh 
```

## 远程SSH进入镜像
方便vscode调试，证书同宿主机
```shell
ssh -p 端口 root@IP
```