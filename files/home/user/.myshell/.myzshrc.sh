#/bin/bash
plugins=(
    git
    extract #适配解压命令，只需要extract 文件名
    command-not-found #输入一条不存在的命令时，会自动查询这条命令可以如何获得
    safe-paste #往 zsh 粘贴脚本时，不会被立刻运行
    # 第三方
    zsh-autosuggestions #自动完成历史命令
    zsh-syntax-highlighting #必须在最后，shell 命令的代码高亮
)

[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh
source ~/.myshell/x.sh && source ~/.myshell/alias.sh
[[ -s ~/.myshell/proxy.sh ]] && source ~/.myshell/proxy.sh
