#!/bin/bash

##############################################
# config

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

# /etc/sudoers.d/all
# Cmnd_Alias SVR_CMD =  /bin/apt,/usr/bin/docker,/usr/bin/chsh,/bin/mysql
# a ALL=(ALL) NOPASSWD: SVR_CMD
# b ALL=(ALL) NOPASSWD: SVR_CMD,/usr/bin/veracrypt

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
    
    if ! [ -x "$(command -v lua)" ]; then
        echo 'Error: lua is not installed.' >&2
        fail='y'
    fi
    
    if [ "$fail" = "y" ]; then
        if [ -x "$(command -v apt)" ]; then
            echo "Attempting to install missing tools via apt..."
            sudo apt update
            sudo apt install -y git zsh curl lua5.4 || { echo "install fail: apt install -y git zsh curl lua5.4." >&2; exit -1; }
            echo "Successfully installed missing tools via apt."
        else
            echo "Error: apt is not installed. Cannot install missing tools: apt install -y git zsh curl lua5.4" >&2
            exit -1
        fi
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
echo 'check proxy(如果卡太久，就Ctrl+c，再运行一次)...'
use_proxy="n"
github_mirror="gitclone.com/github.com"
if curl -IsL https://github.com --connect-timeout 2 --max-time 2 | grep " 200" > /dev/null; then
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
    echo "add GitHub520"
    sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
fi

echo "use_proxy=$use_proxy"
if [ "$use_proxy" != "n" ];then
    echo '''
#/bin/bash
alias xopenproxy="export http_proxy='''$use_proxy''';export https_proxy='''$use_proxy''';echo \"HTTP Proxy on\";"
alias xcloseproxy="export http_proxy=;export https_proxy=;echo \"HTTP Proxy off\";"
    ''' > ~/.myshell/proxy.sh
    echo "http_proxy=$use_proxy"
else
    echo '#/bin/bash' > ~/.myshell/proxy.sh
fi

# 非交互下，默认alias不生效，所以这里要手动开启
shopt -s expand_aliases
echo "source ~/.myshell/proxy.sh"
source ~/.myshell/proxy.sh

#########################

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
if [ "$use_proxy" != "n" ];then
    xopenproxy
fi

if ! [ -d ~/.myshell/.z.lua ]; then
    echo "install z.lua...."
    git clone https://$github_mirror/skywind3000/z.lua.git ~/.myshell/.z.lua
else
    echo "use current z.lua"
fi

# 如果出现类似gnutls_handshake() failed: The TLS connection was non-properly terminated.的错误，则切换代理
# chmod +x $SCRIPT_DIR/tools/ohmyzsh.sh && sh -c "$SCRIPT_DIR/tools/ohmyzsh.sh --unattended --keep-zshrc"
# 如果已经有oh-my-zsh了，就不再安装
if ! [ -d ~/.oh-my-zsh ]; then
    echo "install oh-my-zsh...."
    sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended
else
    echo "use current ~/.oh-my-zsh."
fi

if ! [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    echo "install zsh-syntax-highlighting...."
    git clone https://$github_mirror/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
    echo "use current zsh-syntax-highlighting."
fi
if ! [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    echo "install zsh-autosuggestions...."
    git clone https://$github_mirror/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    echo "use current zsh-autosuggestions."
fi

sed -i '/.myshell/d' ~/.zshrc
echo "source ~/.myshell/.myzshrc" >> ~/.zshrc

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
########################

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

sudo sed -i 's|#MaxAuthTries.*|MaxAuthTries 20|' /etc/ssh/sshd_config
