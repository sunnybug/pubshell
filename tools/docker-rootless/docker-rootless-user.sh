#!/bin/bash
set -e

# 不能是root
if [ "$(id -u)" = "0" ]; then
    echo "不允许root执行"
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

####################
#开机自启
if sudo loginctl show-user "$USER" | grep -qw 'Linger=yes'; then
    echo "当前用户服务已经设置为开机自启"
else
    echo "是否允许当前用户服务开机自启:y/n"
    read -r user_input
    if [[ "$user_input" == "y" ]]; then
        echo "sudo loginctl enable-linger $USER"
        if sudo loginctl enable-linger "$USER"; then
            echo "成功设置开机自启。"
        else
            echo "无法设置开机自启，请检查权限或联系管理员。"
        fi
    else
        echo '禁止当前用户服务开机自启'
    fi
fi

###############
# 检查PATH是否已经包含~/bin
current_path="$PATH"
if [[ "$current_path" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "Added '~/bin' to PATH in ~/.bashrc"
else
    echo " '~/bin' is already in PATH"
fi

###############
# 检查DOCKER_HOST环境变量是否已设置
if [ -z "$DOCKER_HOST" ]; then
    # 环境变量未设置，将其添加到~/.bashrc
    echo 'export DOCKER_HOST=unix://run/user/1000/docker.sock' >> ~/.bashrc
    echo "DOCKER_HOST set to 'unix://run/user/1000/docker.sock' in ~/.bashrc"
else
    echo "DOCKER_HOST is already set to '$DOCKER_HOST'"
fi