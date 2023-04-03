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
# auto del,auto add,auto commit,and auto push...
alias gitpushall='git add . && git ls-files --deleted -z | xargs -0 git rm ; git commit -m "auto-commit" && git push'

# 模糊查找进程名，显示pid和进程路径
alias pspath='function _findproc(){ ps aux | grep -i $1 | grep -v grep | awk "{print \$2, \$11}" | column -t | sed "1i PID  Path" ;};_findproc'

# 删除模糊匹配字符串的历史记录
# histdel xxx
alias histdel='function __histdel(){grep -v "$1" ~/.zsh_history > /tmp/zsh_history && mv /tmp/zsh_history ~/.zsh_history; grep -v "$1" ~/.bash_history > /tmp/bash_history && mv /tmp/bash_history ~/.bash_history;};__histdel' 

if command -v apt-fast &> /dev/null
then
  alias apt=apt-fast
fi

