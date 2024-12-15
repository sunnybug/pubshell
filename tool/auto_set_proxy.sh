#/bin/bash
shopt -s expand_aliases

# xproxy.sh
script_path=$(dirname "$(realpath "$0")")
tempfile="$script_path/tool/xproxy.sh"
if [ ! -f "$tempfile" ]; then
    tempfile=$(mktemp)
    echo '[WRN]download xproxy.sh'
    curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/tool/xproxy.sh -o "$tempfile"
fi
source "$tempfile"

xopenproxy
alias xopenproxy
echo "[auto_set_proxy]http_proxy:$http_proxy"
