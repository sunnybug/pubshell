#!/bin/bash

# 不能是root
# if [ "$(id -u)" = "0" ]; then
#     echo "不允许root执行"
#     exit 1
# fi


################
# 检查是否能正常访问
if ! curl -fsSL --connect-timeout 3 --max-time 3 https://get.docker.com/rootless | grep -q "/docs.docker.com/"; then
    echo "can not access https://get.docker.com/rootless"
    exit 1
else
    echo "网络检查通过: https://get.docker.com/rootless"
fi

if systemctl --user is-active docker &>/dev/null; then
    systemctl --user stop docker
fi

curl -fsSL https://get.docker.com/rootless | FORCE_ROOTLESS_INSTALL=1 sh
systemctl --user --now enable docker

####################
#开机自启
if loginctl show-user "$USER" | grep -qw 'Linger=yes'; then
    echo "当前用户服务已经设置为开机自启"
else
    echo "root执行:"
    echo "sudo loginctl enable-linger $USER"
fi

###############
# 检查PATH是否已经包含~/bin
current_path="$PATH"

if [[ ! "$current_path" =~ *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "[SUC] Added '~/bin' to PATH in ~/.bashrc"
else
    echo "[SUC] '~/bin' is already in PATH"
fi

###############
# 检查DOCKER_HOST环境变量是否已设置
if [ -z "$DOCKER_HOST" ]; then
    # 环境变量未设置，将其添加到~/.bashrc
    echo 'export DOCKER_HOST=unix://run/user/$UID/docker.sock' >> ~/.bashrc
    echo "[SUC] DOCKER_HOST set to 'unix://run/user/$UID/docker.sock' in ~/.bashrc"
else
    echo "[SUC] DOCKER_HOST is already set to '$DOCKER_HOST'"
fi

curl -sSfL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/tool/config_docker.sh | bash

#################################
# docker compose plugin
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.29.6/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

#################################
echo "[SUC] Docker Rootless 安装完成,请重新登录"