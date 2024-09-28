# 说明
支持docker rootless模式

# root用户（每个机器只需要运行一次）
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/root_tools/docker-rootless/docker-rootless-root.sh | sh

# 普通用户(每个用docker的用户都需要运行一次)
curl -sSL https://gitee.com/sunnybug/pubshell/raw/main/root_tools/docker-rootless/docker-rootless-user.sh | sh
