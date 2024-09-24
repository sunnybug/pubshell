#/bin/bash

export no_proxy="gitclone.com,gitee.com,127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mirrors.tencent.com,mirrors.aliyun.com"

#########################
github_mirror="gitclone.com/github.com"

xdetectproxy(){
    echo 'check proxy(如果卡太久，就Ctrl+c，再运行一次)...'
    use_proxy="n"
    if ! curl -fsSL --connect-timeout 3 --max-time 3 https://github.com/login | grep -q "/githubusercontent.com/"; then
        echo 'curl github.com success'
        github_mirror="github.com"
        use_proxy="n"
    fi
    
    if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        my_proxy='http://192.168.1.199:10816'
        use_proxy="y"
        elif curl -IsL http://127.0.0.1:10811 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        my_proxy='http://127.0.0.1:10811'
        use_proxy="y"
        elif curl -IsL http://192.168.1.186:10813 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        my_proxy='http://192.168.1.186:10813'
        use_proxy="y"
    fi
    
    # 如果当前用户是root
    # if [ "$USER" = "root" ]; then
    #     echo "add GitHub520"
    #     sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
    # fi
    
    echo "my_proxy=$my_proxy"
    
    # create file
    if ! [ -d ~/.myshell ]; then
        mkdir ~/.myshell
        echo '未检测到.myshell目录，建议安装pubshell'
    fi
    echo $my_proxy > ~/.myshell/.proxy
}

# read file to $my_proxy
if [ -e ~/.myshell/.proxy ]; then
    my_proxy=$(cat ~/.myshell/.proxy)
else
    echo 'no ~/.myshell/.proxy'
fi

alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
alias xopenproxy="export http_proxy='''$my_proxy''';export https_proxy='''$my_proxy''';echo \"HTTP Proxy:$my_proxy\";"
