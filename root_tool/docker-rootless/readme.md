# 说明
支持docker rootless模式

# root用户（每个机器只需要运行一次）
curl -sSL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/root_tool/docker-rootless/docker-rootless-root.sh | sudo bash

# root用户对每个用户执行以下命令，以允许每个用户的rootless docker服务开机自启动
sudo loginctl enable-linger 用户名

# 普通用户(每个用docker的用户都需要运行一次)
curl -sSL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/root_tool/docker-rootless/docker-rootless-user.sh | bash

# root 查看所有用户的容器
curl -sSL https://raw.githubusercontent.com/sunnybug/pubshell/refs/heads/main/root_tool/docker-rootless/list-all.sh | bash