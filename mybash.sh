#!/bin/bash
set -e

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

source ~/.myshell/tools/svn_store_password.sh

#########################
source ~/.myshell/tools/proxy.sh
xdetectproxy
if [ "$use_proxy" == "y" ];then
    xopenproxy
fi

source $SCRIPT_DIR/install/install_omz.sh

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
source ~/.myshell/tools/pip_mirror.sh
source ~/.myshell/tools/docker_mirror.sh
source ~/.myshell/tools/ssh_config.sh


## 安装时zsh会处理，而且这里拿到的$SHELL依然是旧的
# 判断是否是zsh
# curr_shell="$(echo $SHELL)"
# if [[ "$curr_shell" != "/bin/zsh" ]]; then
#     echo "将默认shell修改为zsh"
#     chsh -s $(which zsh)
# fi

echo 'init mybash suc'
echo '1.1' > ~/.myshell/ver
exec zsh -l