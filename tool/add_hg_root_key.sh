#!/bin/bash


my_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCUZuVaC48qdqGKHMzyx1PPXzwCdSFopJCqe+VbFm8FaGGZ1JzsABBxjzkfC9E84yMnhoodgC492zSHolx+509jdSByAbHIs5P/AnavRFikEmf3WEZ1vB4zxxeL/JhRIwkGaR4SsK8OVU5LVh6n2OE0+Ept7YQB5RNwXw0VHt8DJ789ygv4QU1gF5++WNDC/P0uM3ZZgb3QM3WZDVMVAhEdqsk2BAUY6b+Lhz92o33ujU6EbIcs1vYTXL3kVvwxdRCafHc4JNRnCf/2uOPWHLuf2WeJjHp8GT6EiatVOsLwNF+cFMhV8oeeSohhbv7+VkFTgCF5BXSU+cWWKyKLiIsljr4eWavlaDLCgw04YMGYqPCrv7nL5XZZ1BgntAzDFnOsP1VlQS/dGimA7Elb51duSwODpmlirZr8wzmNH/bkgnSwykf8vI4gdmOLkhKTxrAWVEcI+AO652VFl1jSQgJVV4AXcluKv9Tvd2Xhy4CIDIAAwmE+4SB91werf5AmcqM= hxsw"

echo "add my pub key...."
mkdir -p ~/.ssh/
if [ ! -e ~/.ssh/authorized_keys ]; then
    touch ~/.ssh/authorized_keys
fi
grep -q "$my_pubkey"  ~/.ssh/authorized_keys || echo "$my_pubkey" >>  ~/.ssh/authorized_keys

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

# sudo sed -i 's|#MaxAuthTries.*|MaxAuthTries 20|' /etc/ssh/sshd_config
