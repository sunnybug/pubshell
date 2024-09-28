#!/bin/bash

# 检查是否传递了一个参数
deactivate () {
    # reset old environment variables
    if [ -n "${_OLD_VIRTUAL_PATH:-}" ] ; then
        PATH="${_OLD_VIRTUAL_PATH:-}"
        export PATH
        unset _OLD_VIRTUAL_PATH
    fi
    if [ -n "${_OLD_VIRTUAL_PYTHONHOME:-}" ] ; then
        PYTHONHOME="${_OLD_VIRTUAL_PYTHONHOME:-}"
        export PYTHONHOME
        unset _OLD_VIRTUAL_PYTHONHOME
    fi

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "${BASH:-}" -o -n "${ZSH_VERSION:-}" ] ; then
        hash -r 2> /dev/null
    fi

    if [ -n "${_OLD_VIRTUAL_PS1:-}" ] ; then
        PS1="${_OLD_VIRTUAL_PS1:-}"
        export PS1
        unset _OLD_VIRTUAL_PS1
    fi

    unset VIRTUAL_ENV
    unset VIRTUAL_ENV_PROMPT
    if [ ! "${1:-}" = "nondestructive" ] ; then
    # Self destruct!
        unset -f deactivate
    fi
}

activate(){
    local arg1=$1
    VIRTUAL_ENV=$(readlink -f "$arg1")
    export VIRTUAL_ENV

    _OLD_VIRTUAL_PATH="$PATH"
    PATH="$VIRTUAL_ENV/bin:$PATH"
    export PATH

    # unset PYTHONHOME if set
    # this will fail if PYTHONHOME is set to the empty string (which is bad anyway)
    # could use `if (set -u; : $PYTHONHOME) ;` in bash
    if [ -n "${PYTHONHOME:-}" ] ; then
        _OLD_VIRTUAL_PYTHONHOME="${PYTHONHOME:-}"
        unset PYTHONHOME
    fi

    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ] ; then
        _OLD_VIRTUAL_PS1="${PS1:-}"
        PS1="(.venv) ${PS1:-}"
        export PS1
        VIRTUAL_ENV_PROMPT="(.venv) "
        export VIRTUAL_ENV_PROMPT
    fi

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "${BASH:-}" -o -n "${ZSH_VERSION:-}" ] ; then
        hash -r 2> /dev/null
fi

}



entry_venv() {
    local should_exit=0
    local current_dir=$(pwd)
    
    # unset irrelevant variables
    deactivate nondestructive


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
        activate $venv_dir
        cd "$current_dir"
    fi
}

