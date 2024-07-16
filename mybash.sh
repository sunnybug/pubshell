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

source $SCRIPT_DIR/install/check_tools.sh
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

source $SCRIPT_DIR/install/svn_store_password.sh
svn_store_password

#########################
source ~/.myshell/proxy.sh
xdetectproxy
if [ "$use_proxy" == "y" ];then
    xopenproxy
fi

source $SCRIPT_DIR/install/install_omz.sh
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

#######################
source $SCRIPT_DIR/install/worknet_pip.sh
init_worknet_pip

source $SCRIPT_DIR/install/ssh_config.sh
init_ssh_config

curr_shell="$(echo $SHELL)"
# 判断是否是zsh
if [[ "$curr_shell" != "/bin/zsh" ]]; then
    echo "将默认shell修改为zsh"
    chsh -s $(which zsh)
fi

echo 'init mybash suc'
echo '1.1' > ~/.myshell/ver
exec zsh -l