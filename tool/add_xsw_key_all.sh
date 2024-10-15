#!/bin/bash



echo "add my pub key...."
my_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCUZuVaC48qdqGKHMzyx1PPXzwCdSFopJCqe+VbFm8FaGGZ1JzsABBxjzkfC9E84yMnhoodgC492zSHolx+509jdSByAbHIs5P/AnavRFikEmf3WEZ1vB4zxxeL/JhRIwkGaR4SsK8OVU5LVh6n2OE0+Ept7YQB5RNwXw0VHt8DJ789ygv4QU1gF5++WNDC/P0uM3ZZgb3QM3WZDVMVAhEdqsk2BAUY6b+Lhz92o33ujU6EbIcs1vYTXL3kVvwxdRCafHc4JNRnCf/2uOPWHLuf2WeJjHp8GT6EiatVOsLwNF+cFMhV8oeeSohhbv7+VkFTgCF5BXSU+cWWKyKLiIsljr4eWavlaDLCgw04YMGYqPCrv7nL5XZZ1BgntAzDFnOsP1VlQS/dGimA7Elb51duSwODpmlirZr8wzmNH/bkgnSwykf8vI4gdmOLkhKTxrAWVEcI+AO652VFl1jSQgJVV4AXcluKv9Tvd2Xhy4CIDIAAwmE+4SB91werf5AmcqM= hxsw"

if [ "$(id -u)" != "0" ]; then
   echo "错误：你需要root权限来运行这个脚本。" >&2
   exit 1
fi

for user_dir in /home/*; do
  if [ -d "$user_dir" ]; then
    username=$(basename "$user_dir")

    # 检查.ssh目录是否存在
    ssh_dir="$user_dir/.ssh"
    if [ ! -d "$ssh_dir" ]; then
        mkdir -p "$ssh_dir"
        chown "$username:$username" "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi

    # 检查.ssh/authorized_keys文件是否存在
    authorized_keys="$ssh_dir/authorized_keys"
    if [ ! -f "$authorized_keys" ]; then
        touch "$authorized_keys"
        chown "$username:$username" "$authorized_keys"
        chmod 600 "$authorized_keys"
    fi
    echo "add my pub key to $username"
    grep -q "$my_pubkey"  "$authorized_keys" || echo "$my_pubkey" >>  "$authorized_keys"
  fi
  
done
