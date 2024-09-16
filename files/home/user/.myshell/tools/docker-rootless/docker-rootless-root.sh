#!/bin/bash

echo 'just run once'

sudo apt install -y uidmap fuse-overlayfs dbus-user-session slirp4netns
sudo systemctl disable --now docker.service docker.socket
