#!/bin/bash
set -e

# export LANG=en_US.UTF-8
# 检查 /etc/profile 中是否存在 "LANG=en_US.UTF-8"
# if ! grep -q "LANG=en_US.UTF-8" /etc/profile; then
#     echo "LANG=en_US.UTF-8" >> /etc/profile
#     echo "LANGUAGE=en_US.UTF-8" >> /etc/profile
#     echo "LC_ALL=en_US.UTF-8" >> /etc/profile
# fi

# source /etc/profile

# 检查$LANG环境变量是否定义
if [ -z "$LANG" ]; then
    echo "错误：\$LANG 未定义。请设置 \$LANG 环境变量。"
    exit 1
fi
apt install locales  locales-all -y

locale-gen $LANG && update-locale LANG=$LANG

