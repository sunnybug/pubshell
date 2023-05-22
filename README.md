# pubshell
注意：会自动加上我个人公钥，如果是个人使用的环境请注意修改my_pubkey变量！

## 以管理员身份安装dev工具
`
git clone https://jihulab.com/sunnybug/pubshell.git && bash pubshell/install.sh --dev && rm -rf pubshell
`
## 以管理员身份安装CPP服务器所需工具
`
git clone https://jihulab.com/sunnybug/pubshell.git && bash pubshell/install.sh --cppserver && rm -rf pubshell
`
## 初始化当前用户环境(alias/.bashrc/.zshrc/proxy)
`
git clone https://jihulab.com/sunnybug/pubshell.git && bash pubshell/mybash.sh && rm -rf pubshell
`
or
`
git clone git@jihulab.com:sunnybug/pubshell.git && bash pubshell/install.sh && rm -rf pubshell
`

## 添加证书
`
curl -sSL https://jihulab.com/sunnybug/pubshell/-/raw/main/add_pubkey.sh | sh
`
## 目的
方便debian用户初始化，会覆盖部分配置文件

## 功能
1. zsh-autosuggestions
   历史命令自动完成
2. z
   输入`z 模糊目录名`快速跳转到最近进过的目录
   使用技巧：https://cloud.tencent.com/developer/article/1694849
3. 自动检测内网代理/pip自建源
4. 适配apt-fast(如果存在)
5. 一些简化的alias，见.myshell/alias.sh
6. venv命令，支持在当前目录下自动查找python的venv环境并激活