#/bin/bash
###
 # @Date: 2023-03-24
 # @Description: 
 # @LastEditTime: 2023-04-22
 # @LastEditors: xushuwei
### 
alias l="ls -lh --color=auto"
alias ll="ls -lah --color=auto"
alias ls="ls --color=auto"

alias his=history
# auto del,auto add,auto commit,and auto push...
alias gitpushall='git add -A && git commit -m "commit" && git push'
alias gc='git add -A && git commit --message'

# 模糊查找进程名，显示pid和进程路径
alias pspath='_findproc() { printf "%-10s %-15s %-10s %-50s %s\n" "PID" "USER" "MEM" "PATH"; ps aux | grep -i $1 | grep -v grep | awk '"'"'{print $2}'"'"' | while read pidvar; do uservar=$(ps -o user= -p $pidvar); memvar=$(( $(ps -o rss= -p $pidvar) / 1024 ))MB; pathvar=$(readlink "/proc/$pidvar/exe"); printf "%-10s %-15s %-10s %-50s %s\n" "$pidvar" "$uservar" "$memvar" "$pathvar"; done | column -t;}; _findproc'

# 删除模糊匹配字符串的历史记录
# histdel xxx
alias histdel='function __histdel(){grep -v "$1" ~/.zsh_history > /tmp/zsh_history && mv /tmp/zsh_history ~/.zsh_history; grep -v "$1" ~/.bash_history > /tmp/bash_history && mv /tmp/bash_history ~/.bash_history;};__histdel' 

if command -v apt-fast &> /dev/null
then
  alias apt=apt-fast
fi

