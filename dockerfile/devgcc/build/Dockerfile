FROM debian:bookworm

# 定义构建时的参数
ARG gcc_ver=0

####################################################################
#base 
EXPOSE 22/tcp

ENV TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./
 
COPY file/sources.list /etc/apt/sources.list
RUN echo '' > /etc/apt/sources.list.d/debian.sources
COPY file/preferences /etc/apt/preferences

SHELL ["/bin/bash", "-c"]

RUN apt update\
    && apt install --no-install-recommends -y gdb make ninja-build vim jq ssh p7zip-full python3.12-minimal python3-pip python3.12-venv subversion git zip curl wget zsh sudo lua5.4\
    # 未知问题：这之后系统变成了trixie
    && pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/\
    # && pip config set global.trusted-host 192.168.1.20\
    # && pip config set global.index-url http://192.168.1.20:9090/simple/\
    && pip install cmake regex click --break-sys\
    && git config --global user.email "$MY_NAME@x.com"\
    && git config --global user.name "$MY_NAME"\
    && link /usr/bin/python3 /usr/bin/python\
    && mkdir /data\
    && git clone https://gitee.com/sunnybug/pubshell.git /mytool/pubshell \
    && bash /mytool/pubshell/tool/ssh_config.sh \
    && bash /mytool/pubshell/root_tool/locale.sh \
    # llvm    
    && apt install -y --no-install-recommends apt-transport-https ca-certificates debian-keyring gnupg\
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421 \
    && gpg --export --armor 15CF4D18AF4F7421 | apt-key add - \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/llvm-apt/bookworm/ llvm-toolchain-bookworm-19 main' > /etc/apt/sources.list.d/llvm.list \
    && apt update \
    && apt install --no-install-recommends -y llvm-19 clang-19 clang-format-19 clang-tidy-19 clang-tools-19 libc++-19-dev libc++abi-19-dev \
    &&  link /usr/bin/clang-19 /usr/bin/clang\
    &&  link /usr/bin/clang++-19 /usr/bin/clang++\
    &&  link /usr/bin/clang-format-19 /usr/bin/clang-format\
    &&  link /usr/bin/clang-tidy-19 /usr/bin/clang-tidy \
    &&  link /usr/bin/clang-apply-replacements-19 /usr/bin/clang-apply-replacements \
    && if [ "$gcc_ver" = "12" ]; then \
        apt install --no-install-recommends -y gcc-12 g++-12 && \
        ln -s /usr/bin/gcc-12 /usr/bin/gcc && \
        ln -s /usr/bin/g++-12 /usr/bin/g++ && \
        ln -s /usr/bin/g++-12 /usr/bin/c++; \
    elif [ "$gcc_ver" = "14" ]; then \
        apt install --no-install-recommends -y gcc-14 g++-14 && \
        ln -s /usr/bin/gcc-14 /usr/bin/gcc && \
        ln -s /usr/bin/g++-14 /usr/bin/g++ && \
        ln -s /usr/bin/g++-14 /usr/bin/c++; \
    else \
        echo "Unsupported GCC version: $gcc_ver" && \
        exit 1; \
    fi \
    && apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'

# distcc
# RUN apt install -y distcc distcc-pump
# COPY file/distcc /etc/default/distcc

    
# RUN apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'




####################################################################
#final
# RUN apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'

WORKDIR /root
# 不能放root下，因为root目录后面会被挂载出去
COPY file/entrypoint.sh /mytool/entrypoint.sh
RUN chmod +x /mytool/entrypoint.sh && rm -rf "/tmp/*"
ENTRYPOINT ["/bin/bash", "-c", "/mytool/entrypoint.sh"]    