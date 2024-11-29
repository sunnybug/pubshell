#!/bin/bash

check_tools() {
    # Check if sudo exists and set command prefix accordingly
    if command -v sudo >/dev/null 2>&1; then
        cmd_prefix="sudo"
    else
        cmd_prefix=""
    fi

    fail='n'
    missing_tools=''
    fail_zsh='n'
    missing_tools_zsh=''
    
    if ! [ -x "$(command -v git)" ]; then
        missing_tools+=" git" 
        fail='y'
    fi
    
    if ! [ -x "$(command -v zsh)" ]; then
        missing_tools_zsh+=" zsh"
        fail_zsh='y'
    fi
    
    if ! [ -x "$(command -v curl)" ]; then
        missing_tools_zsh+=" curl"
        fail_zsh='y'
    fi
    
    if ! [ -x "$(command -v lua)" ]; then
        missing_tools+=" lua"
        fail='y'
    fi
    
    if ! [ -x "$(command -v jq)" ]; then
        missing_tools+=" jq"
        fail='y'
    fi

    if ! [ -x "$(command -v batcat)" ]; then
        missing_tools+=" bat"
        fail='y'
    fi
    
    if [ "$fail" = "y" ]; then
        echo "是否安装？ ${missing_tools}  请输入 (y/n): [可选]"
        read REPLY < /dev/tty
        if [ "$REPLY" = "y" ]; then
            $cmd_prefix apt update && $cmd_prefix apt install ${missing_tools}
            if [ $? -ne 0 ]; then
                echo "安装工具失败" >&2
                exit 1
            fi
        fi
    fi

    if [ "$fail_zsh" = "y" ]; then
        echo "是否安装必需工具？ ${missing_tools_zsh} 请输入 (y/n): "
        read REPLY < /dev/tty
        if [ "$REPLY" = "y" ]; then
            $cmd_prefix apt update && $cmd_prefix apt install ${missing_tools_zsh}
            if [ $? -ne 0 ]; then
                echo "安装工具失败" >&2
                exit 1
            fi
        else
            echo "缺少必需工具，无法使用pubshell" >&2
            exit 1
        fi
    fi
}

check_tools