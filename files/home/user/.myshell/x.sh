#/bin/bash

TRAPEXIT() {
    if [[ ! -o login ]]; then
        if [ -e "~/.zlogout" ]; then
            . ~/.zlogout
        fi
    fi
}
set HISTCONTROL ignorespace

if [ -x /usr/bin/dircolors ] ; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# pip install会安装到~/.local/bin
export PATH=~/.local/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./

TERM=xterm-256color
if [ -z "$BASH" ]; then # 先判断不处于bash
    if [[ "$SHELL" =~ "zsh" ]] ; then
        bindkey  "^[[H"   beginning-of-line
        bindkey  "^[[F"   end-of-line
        bindkey  "^[[3~"  delete-char
    fi
fi
ulimit -c unlimited #for coredump

if command -v thefuck &> /dev/null
then
    eval $(thefuck --alias)
fi

