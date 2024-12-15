C++开发用的镜像

## 傻瓜版
以容器名为dev-ga为例
curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/install/webinstall_pubshell.sh | bash
curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/install/web_create_devgcc.sh | bash -s -- "dev-ga"

编辑~/devgcc/dev-ga/.env中的镜像版本/端口等(否则启动容器时会提示端口冲突)
创建并开启容器
cd ~/devgcc && bash ./start.sh dev-ga
进入容器
cd ~/devgcc && bash ./enter.sh dev-ga
删除容器
cd ~/devgcc && bash ./remove.sh dev-ga
将代码放在/root/下，默认配置下宿主机目录为/home/$USER/容器名_home

## 按需配置.env

## 镜像构建
```shell
build/build.sh --gcc_ver 14 --image_ver 192.168.1.185:5000/devgcc14
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
docker exec -it $mydev_name bash -c 'curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/install/webinstall_pubshell.sh | bash'

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