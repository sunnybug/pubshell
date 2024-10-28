#!/bin/bash

# 定义一个函数来设置conda环境
setup_conda_environment() {
    # 设置conda镜像
    local CONDA_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/anaconda"
    local CONDA_SRC="https://repo.anaconda.com/miniconda"

    # 创建临时目录和文件
    local TEMP_DIR=$(mktemp -d)
    local MINICONDA_SH="${TEMP_DIR}/miniconda.sh"

    # 下载Miniconda安装脚本到临时文件
    local CONDA_INSTALLER_URL="${CONDA_SRC}/Miniconda3-latest-Linux-x86_64.sh"
    curl -fsSL -v -o "${MINICONDA_SH}" "${CONDA_INSTALLER_URL}"

    # 给安装脚本添加执行权限并执行安装
    chmod +x "${MINICONDA_SH}"
    "${MINICONDA_SH}" -b -p "${HOME}/miniconda"

    # .condarc
    echo "channels:" > "${HOME}/.condarc"
    echo "  - ${CONDA_MIRROR}/pkgs/free/" >> "${HOME}/.condarc"
    echo "  - ${CONDA_MIRROR}/pkgs/main/" >> "${HOME}/.condarc"
    echo "  - ${CONDA_MIRROR}/cloud/pytorch/" >> "${HOME}/.condarc"
    echo "  - defaults" >> "${HOME}/.condarc"
    echo "show_channel_urls: true" >> "${HOME}/.condarc"

    # 将conda的bin目录添加到PATH环境变量，但不影响脚本外部环境
    local CONDA_BIN_PATH="/${HOME}/miniconda/bin"
    echo 'export PATH="$CONDA_BIN_PATH:$PATH"' >> ~/.bashrc
    echo 'export PATH="$CONDA_BIN_PATH:$PATH"' >> ~/.zshrc

    # 安装pytorch、faiss等依赖
    conda install -y pytorch pytorch-cuda=12.4 python=3.12 faiss-gpu pandas -c pytorch -c nvidia
    conda clean -ya
    conda init bash

    # 清理临时目录
    rm -rf "$TEMP_DIR"
}

# 调用函数来设置conda环境
setup_conda_environment