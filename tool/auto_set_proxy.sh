#/bin/bash
shopt -s expand_aliases

script_path=$(dirname "$(realpath "$0")")
tempfile="$script_path/xproxy.sh"
if [ ! -f "$tempfile" ]; then
    tempfile=$(mktemp)
    curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/tool/xproxy.sh -o "$tempfile"
fi

source "$tempfile"

xopenproxy
alias xopenproxy
echo "[auto_set_proxy]http_proxy:$HTTP_PROXY"
