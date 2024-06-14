C++开发用的镜像

## 镜像构建
```shell
docker build -t mydev:gcc12.2 .  --progress=plain
```

docker pull registry.cn-hangzhou.aliyuncs.com/vigoo_pub/mydev:gcc12.2

## 镜像运行
```shell
docker stop mydev && docker remove mydev
docker run -v ~/mydev:/root -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent -itd --name mydev mydev:gcc12.2
docker exec -it mydev /usr/bin/zsh 
```

