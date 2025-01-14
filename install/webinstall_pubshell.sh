#!/bin/bash
set -e

git_repo_url="https://gitee.com/sunnybug/pubshell"

# 接收所有传递给脚本的参数
args=("$@")

# 临时目录
temp_dir=$(mktemp -d)
if [[ ! "$temp_dir" || ! -d "$temp_dir" ]]; then
    echo "Could not create temp directory"
    exit 1
fi

# 克隆 Git 仓库到临时目录
git clone "$git_repo_url" "$temp_dir"

# 检查克隆是否成功
if [[ $? -ne 0 ]]; then
    echo "Git clone failed"
    exit 1
fi

echo "Cloned repo to $temp_dir"

bash $temp_dir/pubshell.sh "${args[@]}"