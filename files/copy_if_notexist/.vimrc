set laststatus=2
set number  "设置行号
set hlsearch    "高亮搜索
set incsearch   "增量搜索，即每次输入新字符都会触发搜索
set autoindent  "自动缩进
set smartindent "智能缩进，基于autoindent
set tabstop=4   "设置一个tab占4个空格
set shiftwidth=4    "每层缩进4个空格
set expandtab   "扩展tab为空格
set softtabstop=4   "使用退格键，每次将删除4个空格
set smarttab    "在行首按TAB将加入shiftwidth个空格，否则加入tabstop个空格
set encoding=utf-8  "vim内部编码方式
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936    "vim打开和保存文件时的编码方式
set termencoding=utf-8  "vim所工作终端的编码方式
set nocompatible    "使用vim自身，而非vi的键盘模式
set history=1000    "在history文件中需要保存的行数
"set clipboard+=unnamed  "与系统共享剪贴板
filetype on "侦测文件类型
set completeopt=longest,menu    "智能补全
syntax enable "语法高亮
syntax on
set showmatch   "高亮显示匹配的括号
set statusline=%F%m%r%h%w\[POS=%l,%v][%p%%]\%{strftime(\"%d/%m/%y\ -\ %H:%M\")} "设置状态栏显示内容
set backspace=2 "解决mac delete键失效问题
filetype plugin on
set omnifunc=syntaxcomplete#Complete "omni自动补全