#!/bin/bash

gfw_need_proxy="y"
gfw_github_ok="n"

function check_gfw(){
    echo "[...]check_gfw"
    
    tmpfile=$(mktemp)
    # check github.com 并将结果保存到临时文件
    response=$(curl -fsSL --connect-timeout 3 --max-time 3 -o "$tmpfile" -w "%{http_code}" https://github.com/login)

    if [ "$response" -eq 200 ]; then
        if grep -q "xxx" "$tmpfile"; then
            echo 'curl github.com success'
            gfw_github_ok="y"
        fi
    fi


    if [ $gfw_github_ok = "n" ]; then
        gfw_need_proxy="y"
    fi

    echo "github.com:   $gfw_github_ok"
    echo "need_proxy:   $gfw_need_proxy"
    echo "[SUC]check_gfw"
}

check_gfw