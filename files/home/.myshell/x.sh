#/bin/bash

TRAPEXIT() {
    if [[ ! -o login ]]; then
        if [ -e "~/.zlogout" ]; then
            . ~/.zlogout
        fi
    fi
}
export HISTCONTROL=ignoreboth

if [ -x /usr/bin/dircolors ] ; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# pip install会安装到~/.local/bin
export PATH=~/bin:~/.local/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./

TERM=xterm-256color
ulimit -c unlimited #for coredump

if command -v thefuck &> /dev/null
then
    eval $(thefuck --alias)
fi
