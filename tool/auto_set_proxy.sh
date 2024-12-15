#/bin/bash
shopt -s expand_aliases

# xhaha.sh
script_path=$(dirname "$(realpath "$0")")
tempfile="$script_path/tool/xhaha.sh"
if [ ! -f "$tempfile" ]; then
    tempfile=$(mktemp)
    echo '[WRN]download xhaha.sh'
    curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/tool/xhaha.sh -o "$tempfile"
fi
source "$tempfile"

xopenproxy
alias xopenproxy
echo "[auto_set_proxy]http_proxy:$http_proxy"
