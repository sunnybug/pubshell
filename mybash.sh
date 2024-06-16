#!/bin/bash

##############################################
# config

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

# /etc/sudoers.d/all
# Cmnd_Alias SVR_CMD =  /bin/apt,/usr/bin/chsh,/bin/mysql
# a ALL=(ALL) NOPASSWD: SVR_CMD
# b ALL=(ALL) NOPASSWD: SVR_CMD,/usr/bin/veracrypt

##############################################

# 非交互下，默认alias不生效，所以这里要手动开启
shopt -s expand_aliases

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
    
    if [ "$fail" = "y" ]; then
        echo "please install missing tools: "
        echo "apt install -y git zsh curl lua5.4"
        exit -1
    fi
}

check_tools

#################################
# 复制配置文件 files/home/user/ 到 ~
if [ -d $SCRIPT_DIR/files/home/user ]; then
    # rsync会改变~的所有者
    # rsync -av --exclude='.oh-my-zsh' $SCRIPT_DIR/files/home/user/ ~
    echo "copy files/home/user/ to ~"
    cp -rTf $SCRIPT_DIR/files/home/user/ ~
else
    echo "Error: $SCRIPT_DIR/files/home/user not found."
    exit -1
fi

#########################
sed -i '/.myshell/d' ~/.bashrc
echo "source ~/.myshell/.myrc" >> ~/.bashrc

patch_svn='''
# patch_svn Start
[global]
store-passwords = yes
store-plaintext-passwords = yes
'''
if ! [ -d ~/.subversion/servers ]; then
    mkdir -p ~/.subversion
    touch ~/.subversion/servers
fi
sed -i "/# patch_svn Start/Q" ~/.subversion/servers && echo "$patch_svn" >> ~/.subversion/servers

#########################
source ~/.myshell/proxy.sh
xdetectproxy
if [ "$use_proxy" == "y" ];then
    xopenproxy
fi

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
    sed -i '/.myshell/d' ~/.zshrc
    echo "source ~/.myshell/.myzshrc" >> ~/.zshrc
}
install_omz

# 必须在omz安装之后
cp -rTf $SCRIPT_DIR/files/home/.oh-my-zsh/ ~/.oh-my-zsh

##################################
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "$USER"
fi

if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "$USER@x.com"
fi

git config --global http.sslVerify false

#################################
# ~下所有目录都只允许本用户访问而且属于本用户（但拦不住root）
# find ~ -name "*" -ls -type d -exec chmod 700 {} \; -exec chown $USER:$USER {} \;
# chown $USER:$USER -R ~
echo "chmod for ~/.ssh"
chown $USER:$USER -R ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

########################
echo "add ssh-rsa to ~/.ssh/config"
if [ ! -f ~/.ssh/config ]; then
    echo "new ~/.ssh/config"
    touch ~/.ssh/config  # 如果文件不存在，则创建一个新的文件
fi

# 检查是否已经存在所需的配置，如果不存在则新增配置
if ! grep -q "HostKeyAlgorithms +ssh-rsa" ~/.ssh/config; then
    echo "HostKeyAlgorithms +ssh-rsa" >> ~/.ssh/config
fi

if ! grep -q "PubkeyAcceptedKeyTypes +ssh-rsa" ~/.ssh/config; then
    echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> ~/.ssh/config
fi

#######################
if [ -x "$(command -v python3)" ]; then
    echo 'check pip host...'
    if curl -IsL http://192.168.1.20:9090/simple --connect-timeout 2 --max-time 2 | grep "200 OK" > /dev/null; then
        pip_host='mypip'
    elif ! [ -z "$(python3 -m pip config get global.trusted-host)" ]; then
        pip_host='aliyun'
    fi

    if [ "$pip_host" = "mypip" ]; then
        python3 -m pip config set global.trusted-host 192.168.1.20
        python3 -m pip config set global.index-url http://192.168.1.20:9090/simple/
    else
        python3 -m pip config set global.index-url http://mirrors.aliyun.com/pypi/simple/
    fi
fi

curr_shell="$(echo $SHELL)"
# 判断是否是zsh
if [[ "$curr_shell" != "/bin/zsh" ]]; then
  echo "将默认shell修改为zsh"
  chsh -s $(which zsh)
fi

echo 'init mybash suc'
echo '1.0' > ~/.myshell/ver
exec zsh -l