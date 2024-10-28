FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04

####################################################################
#base
EXPOSE 22/tcp

ENV TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
SHELL ["/bin/bash", "-c"]
COPY file/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources
RUN apt update\
    && apt install --no-install-recommends -y wget unzip vim jq ssh p7zip-full python3.12-minimal python3-pip python3.12-venv subversion git curl zsh sudo lua5.4\
    && pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/\
    && pip install regex click --break-sys\
    && git config --global user.email "$USER@x.com"\
    && git config --global user.name "$USER"\
    && link /usr/bin/python3 /usr/bin/python\
    && mkdir /data\
    && git clone https://gitee.com/sunnybug/pubshell.git /mytool/pubshell \
    && bash /mytool/pubshell/tool/ssh_config.sh \
    && bash /mytool/pubshell/root_tool/locale.sh

####################################################################
# 安装 miniconda
# ARG CONDA_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/anaconda"
# ENV CONDA_MIRROR=${CONDA_MIRROR}
# ENV CONDA_SRC="https://repo.anaconda.com/miniconda"
# RUN CONDA_SRC="${CONDA_MIRROR}/miniconda"; \
#     curl -fsSL -v -o ~/miniconda.sh -O  "$CONDA_SRC/Miniconda3-latest-Linux-x86_64.sh" && \
#     chmod +x ~/miniconda.sh && \
#     ~/miniconda.sh -b -p /mytool/miniconda && \
#     rm ~/miniconda.sh && \
#     echo "channels:" > $HOME/.condarc && \
#     echo "  - ${CONDA_MIRROR}/pkgs/free/" >> $HOME/.condarc && \
#     echo "  - ${CONDA_MIRROR}/pkgs/main/" >> $HOME/.condarc && \
#     echo "  - ${CONDA_MIRROR}/cloud/pytorch/" >> $HOME/.condarc && \
#     echo "  - defaults" >> $HOME/.condarc && \
#     echo "show_channel_urls: true" >> $HOME/.condarc;
# ENV PATH="/mytool/miniconda/bin:${PATH}"

# # 安装 pytorch
# RUN conda install -y pytorch pytorch-cuda=12.4 python=3.11 faiss-gpu pandas  -c pytorch -c nvidia && \
#     conda clean -ya && \
#     conda init bash
# # 安装相关软件包
# RUN pip install sentence_transformers --break-sys

####################################################################
#final
# RUN apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'

WORKDIR /root
# 不能放root下，因为root目录后面会被挂载出去
COPY file/entrypoint.sh /mytool/entrypoint.sh
RUN chmod +x /mytool/entrypoint.sh && rm -rf "/tmp/*"
ENTRYPOINT ["/bin/bash", "-c", "/mytool/entrypoint.sh"]