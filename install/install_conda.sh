#!/bin/bash

# 定义一个函数来设置conda环境
setup_conda_environment() {
    # 设置conda镜像
    local CONDA_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/anaconda"
    local TEMP_DIR=$(mktemp -d)

    # install miniconda
    if ! [ -d "${HOME}/miniconda" ]; then
        # 创建临时目录和文件
        local MINICONDA_SH="${TEMP_DIR}/miniconda.sh"

        echo "[...]下载Miniconda安装脚本到临时文件"
        curl -fsSL -o "${MINICONDA_SH}" "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

        # 给安装脚本添加执行权限并执行安装
        chmod +x "${MINICONDA_SH}"
        echo "[...]Installing Miniconda..."
        "${MINICONDA_SH}" -b -p "${HOME}/miniconda"
    fi

    # .condarc
    echo "channels:" > "${HOME}/.condarc"
    echo "  - ${CONDA_MIRROR}/pkgs/free/" >> "${HOME}/.condarc"
    echo "  - ${CONDA_MIRROR}/pkgs/main/" >> "${HOME}/.condarc"
    echo "  - ${CONDA_MIRROR}/cloud/pytorch/" >> "${HOME}/.condarc"
    echo "  - defaults" >> "${HOME}/.condarc"
    echo "show_channel_urls: true" >> "${HOME}/.condarc"

    # PATH环境变量
    local CONDA_BIN_PATH="/${HOME}/miniconda/bin"
    if ! grep -q "${CONDA_BIN_PATH}" ~/.bashrc; then
        echo "export PATH=${CONDA_BIN_PATH}:\$PATH" >> ~/.bashrc
    fi
    if ! grep -q "${CONDA_BIN_PATH}" ~/.zshrc; then
        echo "export PATH=${CONDA_BIN_PATH}:\$PATH" >> ~/.zshrc
    fi
    # if [[ ":$PATH:" != *":${CONDA_BIN_PATH}:"* ]]; then
    #     export PATH="${CONDA_BIN_PATH}:$PATH"
    # fi

    # 安装pytorch、faiss等依赖
    echo "[...]conda installing pytorch, faiss, pandas..."
    conda install -y pytorch pytorch-cuda python=3.12 pandas
    conda clean -ya
    conda init bash

    # 清理临时目录
    rm -rf "$TEMP_DIR"

    echo "[SUC]conda安装完成"
}

# 调用函数来设置conda环境
setup_conda_environment