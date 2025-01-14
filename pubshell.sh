#!/bin/bash
# 由于curl会异常，不能开-e
# set -e

##############################################
# config

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
pushd $SCRIPT_DIR

# /etc/sudoers.d/all
# Cmnd_Alias SVR_CMD =  /bin/apt,/usr/bin/chsh,/bin/mysql
# a ALL=(ALL) NOPASSWD: SVR_CMD
# b ALL=(ALL) NOPASSWD: SVR_CMD,/usr/bin/veracrypt

##############################################

# 非交互下，默认alias不生效，所以这里要手动开启
shopt -s expand_aliases

source $SCRIPT_DIR/install/check_tools.sh

#################################
echo "copy files/home/ to ~"
cp -rTf $SCRIPT_DIR/files/home/ ~
cp -rTf $SCRIPT_DIR/tool/ ~/.myshell/tool/
cp -rTf $SCRIPT_DIR/net/ ~/.myshell/net/

#########################
if [ ! -e ~/.bashrc ]; then
    touch ~/.bashrc
fi
sed -i '/.myshell/d' ~/.bashrc
echo "source ~/.myshell/.myrc" >> ~/.bashrc

source ~/.myshell/tool/svn_store_password.sh

#########################
source ~/.myshell/tool/xproxy.sh
xdetectproxy

if [ "$g_use_proxy" == "y" ];then
    xopenproxy
fi

source $SCRIPT_DIR/install/install_omz.sh

# 必须在omz安装之后
cp -rTf $SCRIPT_DIR/files/home/.oh-my-zsh/ ~/.oh-my-zsh

##################################
# 如果有安装git
if [ -x "$(command -v git)" ]; then
    if [ -z "$(git config --global user.name)" ]; then
        git config --global user.name "$(whoami)"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        git config --global user.email "$(whoami)@x.com"
    fi

    git config --global http.sslVerify false
fi
#################################
# ~下所有目录都只允许本用户访问而且属于本用户（但拦不住root）
# find ~ -name "*" -ls -type d -exec chmod 700 {} \; -exec chown $(whoami):$(whoami) {} \;
# chown $(whoami):$(whoami) -R ~

if [ -d ~/.ssh ]; then
    echo "chmod for ~/.ssh"git clone https://gitee.com/sunnybug/pubshell
    chown $(whoami):$(whoami) -R ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
fi

#######################
source ~/.myshell/net/pip_mirror.sh
source ~/.myshell/tool/config_docker.sh
source ~/.myshell/tool/ssh_config.sh

######################
if [ ! -f ~/.vimrc ]; then
    cp $SCRIPT_DIR/files/copy_if_notexist/.vimrc ~/
fi

## 安装时zsh会处理，而且这里拿到的$SHELL依然是旧的
# 判断是否是zsh
# curr_shell="$(echo $SHELL)"
# if [[ "$curr_shell" != "/bin/zsh" ]]; then
#     echo "将默认shell修改为zsh"
#     chsh -s $(which zsh)
# fi

echo 'init pubshell suc'
echo '1.1' > ~/.myshell/ver
exec zsh -l

echo 'install pubshell suc'
popd