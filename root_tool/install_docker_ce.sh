# 只支持镜像操作，不含容器服务
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common --no-install-recommends
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://download.docker.com/linux/debian \
  bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y --no-install-recommends docker-ce-cli
