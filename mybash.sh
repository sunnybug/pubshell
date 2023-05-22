#!/bin/bash

##############################################
# config

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

##############################################
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

    if [ "$fail" = "y" ]; then
        if [ -x "$(command -v apt)" ]; then
            echo "Attempting to install missing tools via apt..."
            sudo apt update
            sudo apt install -y git zsh curl || { echo "Error: Failed to install missing tools via apt." >&2; exit -1; }
            echo "Successfully installed missing tools via apt."
        else
            echo "Error: apt is not installed. Cannot install missing tools." >&2
            exit -1
        fi
    fi
}

check_tools


#################################
# 复制配置文件 files/home/user/ 到 ~
if [ -d $SCRIPT_DIR/files/home/user ]; then
    echo "cp -rTf $SCRIPT_DIR/files/home/user/ ~"
    cp -rTf $SCRIPT_DIR/files/home/user/ ~
else 
    echo "Error: $SCRIPT_DIR/files/home/user not found."
    exit -1
fi

#########################
echo 'check proxy(如果卡太久，就Ctrl+c，再运行一次)...'
use_proxy="n"
github_mirror="gitclone.com/github.com"
if curl -IsL https://github.com --connect-timeout 2 --max-time 2 | grep "200 OK" > /dev/null; then
    echo 'curl github.com success'
    github_mirror="github.com"
    use_proxy="n"
elif curl -IsL http://192.168.1.199:10816 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
    use_proxy='http://192.168.1.199:10816'
elif curl -IsL http://127.0.0.1:10811 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
    use_proxy='http://127.0.0.1:10811'
elif curl -IsL http://192.168.1.186:10813 --connect-timeout 2 --max-time 2 | grep "400 Bad Request" > /dev/null; then
    use_proxy='http://192.168.1.186:10813'
fi

# 如果当前用户是root
if [ "$USER" = "root" ]; then
    sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
fi

echo "use_proxy=$use_proxy"
if [ "$use_proxy" != "n" ];then
    echo '''
#/bin/bash
alias xopenproxy="export http_proxy='''$use_proxy''';export https_proxy='''$use_proxy''';export no_proxy=\"*.gitclone.com,*.gitee.com,127.0.0.1, localhost, 192.168.*,10.*;\";echo \"HTTP Proxy on\";"
alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
    ''' > ~/.myshell/proxy.sh
    export http_proxy=$use_proxy;export https_proxy=$use_proxy;export no_proxy="127.0.0.1, localhost, 192.168.*,10.*";echo "HTTP Proxy on"
    echo "http_proxy=$use_proxy"
else
    echo '#/bin/bash' > ~/.myshell/proxy.sh
fi

# 非交互下，默认alias不生效，所以这里要手动开启
shopt -s expand_aliases
source ~/.myshell/proxy.sh

#########################
source $SCRIPT_DIR/add_pubkey.sh

#########################
patch_bashrc="source ~/.myshell/.myrc"
grep -q "$patch_bashrc" ~/.bashrc  || echo $patch_bashrc >>  ~/.bashrc

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
echo 'install oh-my-zsh...'
rm -rf ~/.oh-my-zsh
rm -rf ~/.myshell/.z

if [ "$use_proxy" != "n" ];then
    xopenproxy
fi 

# 如果出现类似gnutls_handshake() failed: The TLS connection was non-properly terminated.的错误，则切换代理
# chmod +x $SCRIPT_DIR/tools/ohmyzsh.sh && sh -c "$SCRIPT_DIR/tools/ohmyzsh.sh --unattended --keep-zshrc"
sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended

git clone https://github.com/rupa/z.git ~/.myshell/.z
git clone https://$github_mirror/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://$github_mirror/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 从.zshrc中删除source $ZSH/oh-my-zsh.sh，改为从.myzshrc调用
sed -i '' '/source $ZSH\/oh-my-zsh.sh/d' ~/.zshrc
if ! grep -q "source ~/.myshell/.myzshrc" ~/.zshrc; then
    echo "source ~/.myshell/.myzshrc" >> ~/.zshrc
fi

cp -rTf $SCRIPT_DIR/files/home/user/.oh-my-zsh/ ~/.oh-my-zsh

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
chown $USER:$USER -R ~/.ssh


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

echo '默认bash改为zsh'
chsh -s /bin/zsh
