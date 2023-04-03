#/bin/bash
###
 # @Date: 2023-03-01
 # @Description: 
 # @LastEditTime: 2023-03-24
 # @LastEditors: xushuwei
### 
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

