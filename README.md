# pubshell
注意：会自动加上我个人公钥，如果是个人使用的环境请注意修改my_pubkey变量！

## 以管理员身份安装dev工具
`
rm -rf /tmp/pubshell && git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/root_tools/install.sh --dev && rm -rf pubshell
`
## 以管理员身份安装CPP服务器所需工具
`
rm -rf /tmp/pubshell && git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/root_tools/install.sh --cppserver && rm -rf pubshell

## 以管理员身份增加用户
`
rm -rf /tmp/pubshell && git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/root_tools/add_user.sh
`

`
## 初始化当前用户环境(alias/.bashrc/.zshrc/proxy)
`
rm -rf /tmp/pubshell && git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/mybash.sh
`
or
`
rm -rf /tmp/pubshell && git clone https://gitee.com/sunnybug/pubshell /tmp/pubshell && bash /tmp/pubshell/root_tools/install.sh
`

## 添加证书
`
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/tools/add_xsw_key.sh | sh
`
## 目的
方便debian用户初始化，会覆盖部分配置文件

## 限制用户权限
/etc/sudoers.d/目录下添加文件，文件名随意，内容如下：
```
Cmnd_Alias SVR_CMD =  /bin/apt,/usr/bin/docker,/usr/bin/chsh
指定权限 ALL=(ALL) NOPASSWD: SVR_CMD
所有权限 ALL=(ALL)  ALL
```

## 功能
1. zsh-autosuggestions
   历史命令自动完成（不支持模糊匹配）
2. z.lua
   输入`z 模糊目录名`快速跳转到最近进过的目录
   使用技巧：https://github.com/skywind3000/z.lua/blob/master/README.cn.md
3. 自动检测内网代理/pip自建源
4. 适配apt-fast(如果已安装apt-fast)

## 部分常用命令/alias
注：一些简化的alias，见.myshell/alias.sh
| 命令         | 功能                               | 示例          |
|--------------|------------------------------------|---------------|
| venv         | 查找当前目录下的疑似venv目录并激活 | venv          |
| gp           | git pull                           | gp            |
| gc           | git commit -m                      | gc '提交信息' |
| gl           | git pull                           | gl            |
| xopenproxy   | 打开代理                           | xopenproxy    |
| xcloseproxy  | 关闭代理                           | xcloseproxy   |
| xdetectproxy | 检测代理                           | xdetectproxy  |


## 部分常用快捷键
| 快捷键     | 功能                            |
|------------|-------------------------------|
| ctrl+j     | 接受当前的命令行建议(同Right键) |
| ctrl+right | 接受当前建议的单词              |
| Home       | 跳到行首                        |
| End        | 跳到行尾                        |
