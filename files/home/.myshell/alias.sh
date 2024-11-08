#/bin/bash

alias l="ls -lh --color=auto"
alias ll="ls -lah --color=auto"
alias ls="ls --color=auto"
alias his=history
alias gc='git add -A && git commit --message'

# 功能：模糊查找进程名，显示pid和进程路径
alias pspath='_findproc() { printf "%-10s %-15s %-10s %-50s %s\n" "PID" "USER" "MEM" "PATH"; ps aux | grep -i $1 | grep -v grep | awk '"'"'{print $2}'"'"' | while read pidvar; do uservar=$(ps -o user= -p $pidvar); memvar=$(( $(ps -o rss= -p $pidvar) / 1024 ))MB; pathvar=$(readlink "/proc/$pidvar/exe"); printf "%-10s %-15s %-10s %-50s %s\n" "$pidvar" "$uservar" "$memvar" "$pathvar"; done | column -t;}; _findproc'

# 用法：histdel xxx
# 功能：删除模糊匹配字符串的历史记录
alias histdel='function _xhistdel(){grep -v "$1" $HISTFILE > /tmp/history && mv /tmp/history $HISTFILE;};_xhistdel'

if command -v apt-fast &> /dev/null
then
    alias apt=apt-fast
fi

alias venv='source ~/.myshell/venv.sh;entry_venv'
alias sys='systemctl'
alias sysu='systemctl --user'
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Status}}"'
