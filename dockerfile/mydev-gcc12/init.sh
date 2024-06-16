#/bin/bash

# 如果不存在~/.myshell，则执行：
if [ ! -d ~/.myshell ]; then
    git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/mybash.sh
    rm -rf /tmp/pubshell
fi
