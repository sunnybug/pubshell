
#!/bin/bash

check_tools() {
    fail='n'
    if ! [ -x "$(command -v git)" ]; then
        echo '[ERR]git is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v zsh)" ]; then
        echo '[ERR]zsh is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v curl)" ]; then
        echo '[ERR]curl is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v lua)" ]; then
        echo '[ERR]lua is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v jq)" ]; then
        echo '[ERR]jq is not installed.' >&2
        fail='y'
    fi

    if ! [ -x "$(command -v batcat)" ]; then
        echo '[ERR]bat is not installed.' >&2
        fail='y'
    fi
    
    if [ "$fail" = "y" ]; then
        if ! sudo apt install -y git zsh curl lua5.4 jq bat; then
            echo '[ERR]apt install failed.' >&2
            echo '手动执行 sudo apt install -y git zsh curl lua5.4 jq bat' >&2
            exit 1
        fi
    fi
}

check_tools