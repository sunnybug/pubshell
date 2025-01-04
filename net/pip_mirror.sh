#!/bin/bash

auto_pip_mirror() {
    if [ -x "$(command -v python3)" ]; then
        echo 'check pip host...'
        if curl -IsL http://192.168.1.185:9090/simple --connect-timeout 2 --max-time 2 | grep "200 OK" >/dev/null; then
            pip_host='mypip'
        elif ! [ -z "$(python3 -m pip config get global.trusted-host)" ]; then
            pip_host='aliyun'
        fi

        if [ "$pip_host" = "mypip" ]; then
            python3 -m pip config set global.trusted-host 192.168.1.185
            python3 -m pip config set global.index-url http://192.168.1.185:9090/simple/
        else
            python3 -m pip config set global.index-url http://mirrors.aliyun.com/pypi/simple/
        fi
    fi
}

auto_pip_mirror
