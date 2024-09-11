#!/bin/bash
set -e

# 不能是root
if [ "$(id -u)" = "0" ]; then
    echo "please run as non-root user"
    exit 1
fi

mkdir -p ~/.config/systemd/user/docker.service.d

################
# proxy
if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
cat <<EOF > ~/.config/systemd/user/docker.service.d/proxy.conf
[Service]
Environment="HTTP_PROXY=http://192.168.1.199:10816/"
Environment="HTTPS_PROXY=http://192.168.1.199:10816/"
Environment="NO_PROXY=*.aliyuncs.com,*.tencentyun.com,*.cn"
EOF
fi

################
# 检查是否能正常访问
if ! curl -fsSL --connect-timeout 3 --max-time 3 https://get.docker.com/rootless | grep -q "/docs.docker.com/"; then
    echo "can not access https://get.docker.com/rootless"
    exit 1
else
    echo "网络检查通过: https://get.docker.com/rootless"
fi

curl -fsSL https://get.docker.com/rootless | FORCE_ROOTLESS_INSTALL=1 sh
systemctl --user --now enable docker

# 允许用户服务开机自启
echo "sudo loginctl enable-linger $USER"
sudo loginctl enable-linger $USER


###############
#手动处理
cat <<EOF
you should add to ~/.bashrc:
export PATH=\~/bin:\$PATH
export DOCKER_HOST=unix:///run/user/1000/docker.sock
EOF
