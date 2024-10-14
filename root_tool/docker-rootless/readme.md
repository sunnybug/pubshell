# 说明
支持docker rootless模式

# 每个账号需要先安装pubshell
curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/webinstall_pubshell.sh | bash

# root用户（每个机器只需要运行一次）
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/root_tool/docker-rootless/docker-rootless-root.sh | bash

# root用户对每个用户执行以下命令，以允许每个用户的rootless docker服务开机自启动
sudo loginctl enable-linger 用户名

# 普通用户(每个用docker的用户都需要运行一次)
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/root_tool/docker-rootless/docker-rootless-user.sh | bash
