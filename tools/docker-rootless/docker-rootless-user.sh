#!/bin/bash

mkdir -p ~/.config/systemd/user/docker.service.d
cat <<EOF > ~/.config/systemd/user/docker.service.d/proxy.conf
[Service]
Environment="HTTP_PROXY=http://192.168.1.199:10816/"
Environment="HTTPS_PROXY=http://192.168.1.199:10816/"
Environment="NO_PROXY=*.aliyuncs.com,*.tencentyun.com,*.cn"
EOF

curl -fsSL https://get.docker.com/rootless | FORCE_ROOTLESS_INSTALL=1 sh
systemctl --user --now enable docker

cat <<EOF
you should add to ~/.bashrc:
export PATH=\~/bin:\$PATH
export DOCKER_HOST=unix:///run/user/1000/docker.sock
EOF

# 允许用户服务开机自启
echo "sudo loginctl enable-linger $USER"
sudo loginctl enable-linger $USER