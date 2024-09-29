#!/bin/bash
set -e

apt install ccache -y

# 定义源文件路径
source_file="/usr/bin/ccache"

# 定义目标目录
target_dir=~/bin

# 确保目标目录存在
if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
fi

# 要创建的符号链接列表
targets=("g++" "gcc" "g++-12" "gcc-12" "g++-14" "gcc-14")

# 检查并创建符号链接
for target in "${targets[@]}"; do

    if which $target > /dev/null; then
        echo "$target is installed."
    else
        continue
    fi
        
    link_target="$target_dir/$target"
    
    # 检查源文件是否存在
    if [ -f "$source_file" ]; then
        # 检查目标链接位置是否已存在
        if [ ! -e "$link_target" ]; then
            ln -s "$source_file" "$link_target"
            echo "创建符号链接: $source_file -> $link_target"
        else
            echo "目标链接 $link_target 已存在，跳过创建符号链接。"
        fi
    else
        echo "源文件 $source_file 不存在，跳过创建符号链接。"
        break
    fi
done