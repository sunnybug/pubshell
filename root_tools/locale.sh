# export LANG=en_US.UTF-8
# 检查 /etc/environment 中是否存在 "LANG=en_US.UTF-8"
if ! grep -q "LANG=en_US.UTF-8" /etc/environment; then
    echo "LANG=en_US.UTF-8" >> /etc/environment
fi
source /etc/environment
apt install locales  locales-all -y
locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
