## 傻瓜版
以容器名为mycuda为例
curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/web_create_devgcc.sh | bash -s -- "mycuda"

编辑~/devgcc/mycuda/.env中的镜像版本/端口等(否则启动容器时会提示端口冲突)
创建并开启容器
cd ~/devgcc && bash ./start.sh mycuda
进入容器
cd ~/devgcc && bash ./enter.sh mycuda
删除容器
cd ~/devgcc && bash ./remove.sh mycuda
将代码放在/root/下，默认配置下宿主机目录为/home/$USER/容器名_home

## 按需配置.env

## 镜像构建
```shell
build/build.sh --image_ver 192.168.1.185:5000/mycuda:latest
```
