#!/bin/bash

install_omz(){
    if ! [ -e ~/.myshell/.z.lua/z.lua ]; then
        echo "install z.lua...."
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/skywind3000/z.lua.git ~/.myshell/.z.lua
    else
        echo "use current z.lua"
    fi
    
    # 如果出现类似gnutls_handshake() failed: The TLS connection was non-properly terminated.的错误，则切换代理
    # chmod +x $SCRIPT_DIR/tools/ohmyzsh.sh && sh -c "$SCRIPT_DIR/tools/ohmyzsh.sh --unattended --keep-zshrc"
    # 如果已经有oh-my-zsh了，就不再安装
    if ! [ -e ~/.oh-my-zsh/oh-my-zsh.sh ]; then
        echo "install oh-my-zsh...."
        rm -rf ~/.oh-my-zsh
        rm -rf /tmp/ohmyzsh
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/ohmyzsh/ohmyzsh /tmp/ohmyzsh
        export RUNZSH='no'
        sh -c /tmp/ohmyzsh/tools/install.sh --unattended
        rm -rf /tmp/ohmyzsh
    else
        echo "use current ~/.oh-my-zsh."
    fi
    
    if ! [ -e ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        echo "install zsh-syntax-highlighting...."
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    else
        echo "use current zsh-syntax-highlighting."
    fi
    if ! [ -e ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        echo "install zsh-autosuggestions...."
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    else
        echo "use current zsh-autosuggestions."
    fi
    if ! [ -e ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
        echo "install zsh-history-substring-search...."
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
    else
        echo "use current zsh-history-substring-search."
    fi
    if ! [ -e ~/.oh-my-zsh/custom/plugins/zsh-you-should-use/zsh-you-should-use.plugin.zsh ]; then
        echo "install zsh-you-should-use...."
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/MichaelAquilina/zsh-you-should-use ~/.oh-my-zsh/custom/plugins/zsh-you-should-use
    else
        echo "use current zsh-you-should-use."
    fi
    
    # 替换包含.myshell的行
    sed -i '/.myshell/d' ~/.zshrc
    echo "source ~/.myshell/.myzshrc" >> ~/.zshrc
}
install_omz