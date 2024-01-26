#!/bin/bash
if curl -IsL https://github.com --connect-timeout 2 --max-time 2 | grep " 200" > /dev/null; then
    echo 'curl github.com success'
    else
    echo 'curl github.com fail'

fi