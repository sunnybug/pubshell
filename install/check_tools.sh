
#!/bin/bash

check_tools() {
    fail='n'
    if ! [ -x "$(command -v git)" ]; then
        echo 'Error: git is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v zsh)" ]; then
        echo 'Error: zsh is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v curl)" ]; then
        echo 'Error: curl is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v lua)" ]; then
        echo 'Error: lua is not installed.' >&2
        fail='y'
    fi
    
    if ! [ -x "$(command -v jq)" ]; then
        echo 'Error: jq is not installed.' >&2
        fail='y'
    fi
    
    if [ "$fail" = "y" ]; then
        if ! sudo apt install -y git zsh curl lua5.4 jq; then
            echo 'Error: apt install failed.' >&2
            echo '手动执行 sudo apt install -y git zsh curl lua5.4 jq' >&2
            exit 1
        fi
    fi
}

check_tools