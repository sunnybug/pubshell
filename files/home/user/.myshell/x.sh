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
alias l="ls -lh --color=auto"
alias ll="ls -lah --color=auto"
alias ls="ls --color=auto"

alias his=history
alias f=fuck
alias g=git
alias s=svn
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

eval $(thefuck --alias)

if command -v apt-fast &> /dev/null
then
  echo 'find apt-fast'
  alias apt=apt-fast
fi