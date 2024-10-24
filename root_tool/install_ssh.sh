#!/bin/bash

# sudo visudo -f /etc/sudoers.d/$USER
# $USER ALL=(ALL:ALL) NOPASSWD: ALL

# sudo apt update
# sudo apt install -y git zsh curl lua5.4 jq

sudo apt install -y openssh-server

sudo sed -i 's/^#Port /Port /' /etc/ssh/sshd_config
sudo sed -i 's/^Port .*/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/^#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sudo systemctl restart ssh ssh.socket

# 在宿主机转发端口
# netsh interface portproxy add v4tov4 listenport=2223 listenaddress=0.0.0.0 connectport=2222 connectaddress=172.25.13.184
# netsh interface portproxy add v6tov6 listenport=2223 listenaddress=[::] connectport=2222 connectaddress=[::1]
# netsh interface portproxy delete v6tov6 listenport=2223 listenaddress=[::]
