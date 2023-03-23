#/bin/bash
alias l="ls -lh --color=auto"
alias ll="ls -lah --color=auto"
alias ls="ls --color=auto"

alias his=history
alias g=git
alias s=svn

if command -v apt-fast &> /dev/null
then
  echo 'find apt-fast'
  alias apt=apt-fast
fi

