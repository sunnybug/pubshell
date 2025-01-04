# 配置Docker镜像加速器的通用函数[国内镜像基本被封杀]
# configure_docker_mirror() {
#     local conf="$1"
#     echo '[...]配置Docker镜像加速器...'

#     # 检查是否已配置镜像
#     if grep -q "registry-mirrors" "${conf}"; then
#         echo "registry-mirrors 已经正确配置，无需修改"
#         return
#     fi

#     # 备份现有配置
#     if [ -f "$conf" ]; then
#         mv "$conf" "${conf}.bak.$(date +"%Y%m%d%H%M%S")"
#         g_Change=true
#     fi

#     # 确保配置目录存在
#     mkdir -p "$(dirname "$conf")"

#     # 写入镜像配置
#     cat <<EOF > "$conf"
# {
#     "registry-mirrors": [
#         "https://registry.docker-cn.com",
#         "https://yxzrazem.mirror.aliyuncs.com"
#     ]
# }
# EOF
#     echo "[SUC]镜像加速器配置完成: $conf"
# }

# root模式下配置镜像加速器
# docker_root_mirror() {
#     configure_docker_mirror "/etc/docker/daemon.json"
# }

# rootless模式下配置镜像加速器
# docker_rootless_mirror() {
#     configure_docker_mirror "$HOME/.config/docker/daemon.json"
# }
