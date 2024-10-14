#/bin/bash

export no_proxy="gitclone.com,gitee.com,127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mirrors.tencent.com,mirrors.aliyun.com"

#########################
github_mirror="gitclone.com/github.com"
my_proxy=""

xdetectproxy(){
    echo 'check proxy(如果卡太久，就Ctrl+c，再运行一次)...'
    use_proxy="n"

    # 如果本地存在该文件，则执行
    script_dir=$(dirname "$(realpath "$0")")
    if [ -f "$script_dir/$check_gfw" ]; then
        source "$script_dir/check_gfw.sh"
    else
        curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/tool/check_gfw.sh | bash
    fi

    if [ $gfw_need_proxy = "y" ]; then
        use_proxy="y"
        github_mirror="github.com"
    fi
    
    echo 'check 192.168.1.199:10816'
    if curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        my_proxy='http://192.168.1.199:10816'
        use_proxy="y"
        elif curl -IsL http://127.0.0.1:10811 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
        my_proxy='http://127.0.0.1:10811'
        use_proxy="y"
    fi
    
    # 如果当前用户是root
    # if [ "$(whoami)" = "root" ]; then
    #     echo "add GitHub520"
    #     sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
    # fi
    
    echo "my_proxy=$my_proxy"
    
    # save to file
    if [ -d ~/.myshell ]; then
        echo $my_proxy > ~/.myshell/.proxy
    fi
}

# read file to $my_proxy
if [ -e ~/.myshell/.proxy ]; then
    my_proxy=$(cat ~/.myshell/.proxy)
else
    xdetectproxy
fi

alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
alias xopenproxy="export http_proxy='''$my_proxy''';export https_proxy='''$my_proxy''';echo \"my_proxy:$my_proxy\";"
echo "[SUC]my_proxy:$my_proxy"