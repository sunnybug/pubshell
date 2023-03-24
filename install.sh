#!/bin/bash


# rm -rf pubshell ; git clone git@jihulab.com:sunnybug/pubshell.git && bash pubshell/install.sh

##############################################
# config
my_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCUZuVaC48qdqGKHMzyx1PPXzwCdSFopJCqe+VbFm8FaGGZ1JzsABBxjzkfC9E84yMnhoodgC492zSHolx+509jdSByAbHIs5P/AnavRFikEmf3WEZ1vB4zxxeL/JhRIwkGaR4SsK8OVU5LVh6n2OE0+Ept7YQB5RNwXw0VHt8DJ789ygv4QU1gF5++WNDC/P0uM3ZZgb3QM3WZDVMVAhEdqsk2BAUY6b+Lhz92o33ujU6EbIcs1vYTXL3kVvwxdRCafHc4JNRnCf/2uOPWHLuf2WeJjHp8GT6EiatVOsLwNF+cFMhV8oeeSohhbv7+VkFTgCF5BXSU+cWWKyKLiIsljr4eWavlaDLCgw04YMGYqPCrv7nL5XZZ1BgntAzDFnOsP1VlQS/dGimA7Elb51duSwODpmlirZr8wzmNH/bkgnSwykf8vI4gdmOLkhKTxrAWVEcI+AO652VFl1jSQgJVV4AXcluKv9Tvd2Xhy4CIDIAAwmE+4SB91werf5AmcqM= "

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR
##############################################
echo 'check tools...'
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

if [ "$fail" = "y" ];then
    exit -1
fi

#########################
echo 'check proxy(如果卡太久，就Ctrl+c，再运行一次)...'
use_proxy="n"
if curl -IsL https://github.com --connect-timeout 2 --max-time 2 | grep "200 OK" > /dev/null; then
    echo 'curl github.com success'
    use_proxy="n"
elif curl -IsL http://192.168.1.199:10880 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
    use_proxy='http://192.168.1.199:10880'
elif curl -IsL http://127.0.0.1:10811 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
    use_proxy='http://127.0.0.1:10811'
fi

echo "use_proxy=$use_proxy"
if [ "$use_proxy" != "n" ];then
    echo '''
#/bin/bash
alias xopenproxy="export http_proxy=$use_proxy;export https_proxy=$use_proxy;export no_proxy=\"*.gitclone.com,*.gitee.com,127.0.0.1, localhost, 192.168.*,10.*;\";echo \"HTTP Proxy on\";"
alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
    ''' > ./files/home/user/.myshell/proxy.sh
    export http_proxy=$use_proxy;export https_proxy=$use_proxy;export no_proxy="127.0.0.1, localhost, 192.168.*,10.*";echo "HTTP Proxy on"
    echo "http_proxy=$user_proxy"
fi

#########################
echo "add my pub key...."
mkdir -p ~/.ssh/
grep -q $my_pubkey  ~/.ssh/authorized_keys || echo "$my_pubkey" >>  ~/.ssh/authorized_keys

#########################
patch_bashrc="source ~/.myshell/*.sh"
grep -q $patch_bashrc ~/.bashrc  || echo $patch_bashrc >>  ~/.bashrc

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
sed -i "/# patch_svn Start/Q" ~/.subversion/servers && echo $patch_svn >> ~/.subversion/servers

#########################
echo 'install oh-my-zsh...'
rm -rf ~/.oh-my-zsh
rm -rf ~/.autojump
rm -rf ~/autojump_tmp

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh) --unattended --keep-zshrc"

git clone https://gitclone.com/github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://gitclone.com/github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://gitclone.com/github.com/wting/autojump ~/autojump_tmp && pushd ~/autojump_tmp && ./install.py && popd

##################################
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "$USER"
fi

if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "$USER@x.com"
fi

#################################
if [ -d $SCRIPT_DIR/files/home/user ]; then
    echo "cp -rTf $SCRIPT_DIR/files/home/user/ ~"
    cp -rTf $SCRIPT_DIR/files/home/user/ ~
else 
    echo "Error: $SCRIPT_DIR/files/home/user not found."
    exit -1
fi

#################################
# ~下所有目录都只允许本用户访问而且属于本用户（但拦不住root）
# find ~ -name "*" -ls -type d -exec chmod 700 {} \; -exec chown $USER:$USER {} \; 
# chown $USER:$USER -R ~
chown $USER:$USER -R ~/.ssh
chmod 700 ~/.ssh
chmod 644 ~/.ssh/*

#######################
if [ -x "$(command -v python3)" ]; then
    echo 'check pip host...'
    if curl -IsL http://192.168.1.20:9090/simple --connect-timeout 2 --max-time 2 | grep "200 OK" > /dev/null; then
        pip_host='192.168.1.20'
    elif ! [ -z "$(python3 -m pip config get global.trusted-host)" ]; then
        pip_host='mirrors.aliyun.com'
    fi

    if [ "$pip_host" -gt 1 ]; then
        python3 -m pip config set global.trusted-host $pip_host
        python3 -m pip config set global.index-url http://$pip_host:9090/simple/
    fi
fi

echo '默认bash改为zsh'
chsh -s /bin/zsh
