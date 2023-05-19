#!/bin/bash

# 检查是否传递了一个参数
entry_venv() {
    local should_exit=0
    local current_dir=$(pwd)

    if [ $# -eq 1 ]; then
        # 获取虚拟环境目录
        local venv_dir="$1"

        # 检查目录是否存在
        if [ ! -d "$venv_dir" ]; then
            echo "Error: Directory '$venv_dir' does not exist."
            should_exit=1
        fi

        # 拼接activate脚本路径
        local activate_script="$venv_dir/bin/activate"

        # 检查activate脚本是否存在
        if [ ! -f "$activate_script" ]; then
            echo "Error: Activate script '$activate_script' does not exist."
            cd "$venv_dir" || return
            venv_dir=$(find . -maxdepth 1 -type d -exec test -f '{}/bin/activate' \; -print)
            activate_script="$venv_dir/bin/activate"
            if [ ! -f "$activate_script" ]; then
                echo "Error: Activate script '$activate_script' does not exist."
                should_exit=1
            fi
        fi
    else
        # 在没有传递参数的情况下执行其他操作
        echo "No venv_directory provided. looking for /bin/activate form pwd."
        local venv_dir=$(find . -maxdepth 1 -type d -exec test -f '{}/bin/activate' \; -print)
        echo "$venv_dir"
        local activate_script="$venv_dir/bin/activate"
        if [ ! -f "$activate_script" ]; then
            echo "Error: Activate script '$activate_script' does not exist."
            should_exit=1
        fi
        # 在这里添加您希望执行的其他命令或操作
    fi

    if [ $should_exit -eq 1 ]; then
        echo "Exiting."
        cd "$current_dir"
    else
        echo "Found venv script in ${activate_script}"
        source "$activate_script"
        cd "$current_dir"
    fi
}

