#/bin/bash

# 如果不存在~/.myshell/ver，则执行：
if [ ! -d ~/.myshell/ver ]; then
    git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/mybash.sh
    rm -rf /tmp/pubshell
    echo 'init suc'
else
    echo '~/.myshell/ver exists'
fi

service ssh start
tail -f /dev/null
