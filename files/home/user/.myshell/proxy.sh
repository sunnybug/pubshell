
#/bin/bash
alias xopenproxy="export http_proxy=http://192.168.1.199:10880;export https_proxy=http://192.168.1.199:10880;export no_proxy=\"*.gitclone.com,*.gitee.com,127.0.0.1, localhost, 192.168.*,10.*;\";echo \"HTTP Proxy on\";"
alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
    
