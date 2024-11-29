#!/bin/bash

check_tools() {
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
        read -p "是否安装？ ${missing_tools} (y/n) [可选]" REPLY
        if [ "$REPLY" = "y" ]; then
            sudo apt update && sudo apt install ${missing_tools}
            if [ $? -ne 0 ]; then
                echo "安装工具失败" >&2
                exit 1
            fi
        fi
    fi

    if [ "$fail_zsh" = "y" ]; then
        read -p "是否安装必需工具？ ${missing_tools_zsh} (y/n) " REPLY
        if [ "$REPLY" = "y" ]; then
            sudo apt update && sudo apt install ${missing_tools_zsh}
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