#!/bin/bash

install_omz(){
    if [ -z "$ZSH_CUSTOM" ]; then
        ZSH_CUSTOM=~/.oh-my-zsh/custom
    fi
    if [ -z "$ZSH" ]; then
        ZSH=~/.oh-my-zsh
    fi
    
    if ! [ -e ~/.myshell/.z.lua/z.lua ]; then
        echo "install z.lua...."
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/skywind3000/z.lua.git ~/.myshell/.z.lua
    else
        echo "use current z.lua"
    fi
    
    # 如果出现类似gnutls_handshake() failed: The TLS connection was non-properly terminated.的错误，则切换代理
    # chmod +x $SCRIPT_DIR/tool/ohmyzsh.sh && sh -c "$SCRIPT_DIR/tool/ohmyzsh.sh --unattended --keep-zshrc"
    # 如果已经有oh-my-zsh了，就不再安装
    if ! [ -e $ZSH/oh-my-zsh.sh ]; then
        echo "install oh-my-zsh...."
        rm -rf $ZSH
        temp_dir=$(mktemp -d)
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/ohmyzsh/ohmyzsh $temp_dir
        export RUNZSH='no'
        sh -c $temp_dir/tools/install.sh --unattended
        rm -rf $temp_dir
    else
        echo "update current $ZSH."
        ~/.oh-my-zsh/tools/upgrade.sh
    fi
    
    if ! [ -e $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        echo "install zsh-syntax-highlighting...."
        rm -rf $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    else
        echo "use current zsh-syntax-highlighting."
    fi
    if ! [ -e $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        echo "install zsh-autosuggestions...."
        rm -rf $ZSH_CUSTOM/plugins/zsh-autosuggestions
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    else
        echo "use current zsh-autosuggestions."
    fi
    if ! [ -e $ZSH_CUSTOM/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
        echo "install zsh-history-substring-search...."
        rm -rf $ZSH_CUSTOM/plugins/zsh-history-substring-search
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/zsh-users/zsh-history-substring-search $ZSH_CUSTOM/plugins/zsh-history-substring-search
    else
        echo "use current zsh-history-substring-search."
    fi
    
    if ! [ -e $ZSH_CUSTOM/plugins/zsh-you-should-use/zsh-you-should-use.plugin.zsh ]; then
        echo "install zsh-you-should-use...."
        rm -rf $ZSH_CUSTOM/plugins/zsh-you-should-use
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/MichaelAquilina/zsh-you-should-use $ZSH_CUSTOM/plugins/zsh-you-should-use
    else
        echo "use current zsh-you-should-use."
    fi
    
    if ! [ -e $ZSH_CUSTOM/plugins/zsh-bat/zsh-bat.plugin.zsh ]; then
        echo "install zsh-bat...."
        rm -rf $ZSH_CUSTOM/plugins/zsh-bat
        GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone https://$github_mirror/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat
    else
        echo "use current zsh-bat."
    fi

    # 替换包含.myshell的行
    sed -i '/.myshell/d' ~/.zshrc
    echo "source ~/.myshell/.myzshrc" >> ~/.zshrc
}
install_omz