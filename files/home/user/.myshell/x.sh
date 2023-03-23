#/bin/bash
###
 # @Date: 2023-03-01
 # @Description: 
 # @LastEditTime: 2023-03-23
 # @LastEditors: xushuwei
### 
TRAPEXIT() {
    if [[ ! -o login ]]; then
      . ~/.zlogout
    fi
  }
set HISTCONTROL ignorespace 

if [ -x /usr/bin/dircolors ] ; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u

# pip install会安装到~/.local/bin
export PATH=~/.local/bin:$PATH 
export LD_LIBRARY_PATH=./

TERM=xterm-256color
if [[ "$SHELL" =~ "zsh" ]] ; then
  bindkey  "^[[H"   beginning-of-line
  bindkey  "^[[F"   end-of-line
  bindkey  "^[[3~"  delete-char
fi
ulimit -c unlimited #for coredump

if command -v thefuck &> /dev/null
then
  eval $(thefuck --alias)
  alias f=fuck
fi

