#/bin/bash
###
 # @Date: 2023-03-24
 # @Description: 
 # @LastEditTime: 2023-03-25
 # @LastEditors: xushuwei
### 
alias l="ls -lh --color=auto"

alias ll="ls -lah --color=auto"
alias ls="ls --color=auto"

alias his=history
alias g=git
alias s=svn

# 模糊查找进程名，显示pid和进程路径
alias pspath='function _findproc(){ ps aux | grep -i $1 | grep -v grep | awk "{print \$2, \$11}" | column -t | sed "1i PID  Path" ;};_findproc'


if command -v apt-fast &> /dev/null
then
  echo 'find apt-fast'
  alias apt=apt-fast
fi

