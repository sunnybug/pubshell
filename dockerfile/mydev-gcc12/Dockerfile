FROM debian:12

####################################################################
#base 
EXPOSE 22/tcp

ENV TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

COPY file/sources.list /etc/apt/sources.list
RUN echo '' > /etc/apt/sources.list.d/debian.sources
COPY file/preferences /etc/apt/preferences

RUN apt update\
    && apt install --no-install-recommends -y ssh nano p7zip-full python3.12-minimal python3-pip python3.12-venv subversion git curl zsh sudo lua5.4\
    # && pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/\
    && pip config set global.trusted-host 192.168.1.20\
    && pip config set global.index-url http://192.168.1.20:9090/simple/\
    && pip install regex click xBaseDev --break-sys\
    && git config --global user.email "$MY_NAME@x.com"\
    && git config --global user.name "$MY_NAME"\
    && unlink /usr/bin/python ; link /usr/bin/python3 /usr/bin/python\
    && mkdir /data\
    && sed -i '/^PubkeyAcceptedAlgorithms/d;$aPubkeyAcceptedAlgorithms +ssh-rsa' /etc/ssh/sshd_config\
    && sed -i 's/\(^#\)\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config\
    && sed -i 's|\(^#\)\?MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config \
    && apt install --no-install-recommends -y gcc-12 g++-12 gdb make cmake ninja-build\
    && link /usr/bin/gcc-12 /usr/bin/gcc\
    && link /usr/bin/g++-12 /usr/bin/g++\
    && link /usr/bin/g++-12 /usr/bin/c++\
    && curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/root_tools/locale.sh | bash

# distcc
# RUN apt install -y distcc distcc-pump
# COPY file/distcc /etc/default/distcc

    
# RUN apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'



####################################################################
# llvm    
# RUN apt update\
#     && apt install -y --no-install-recommends apt-transport-https ca-certificates debian-keyring gnupg\
#     && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B\
#     && gpg --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421\
#     && gpg --armor --export 15CF4D18AF4F7421 | apt-key add -\
#     && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/llvm-apt/bookworm/ llvm-toolchain-bookworm-18 main' >>  /etc/apt/sources.list\
#     && apt update
    
# RUN apt install --no-install-recommends -y llvm-18 clang-18 clang-format-18 clang-tidy-18 clang-tools-18 libc++-18-dev libc++abi-18-dev \
#     &&  link /usr/bin/clang-18 /usr/bin/clang\
#     &&  link /usr/bin/clang++-18 /usr/bin/clang++\
#     &&  link /usr/bin/clang-format-18 /usr/bin/clang-format\
#     &&  link /usr/bin/clang-tidy-18 /usr/bin/clang-tidy

####################################################################
#final
# RUN apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'

WORKDIR /root
# 不能放root下，因为root目录后面会被挂载出去
COPY file/entrypoint.sh /mytools/entrypoint.sh
RUN chmod +x /mytools/entrypoint.sh
ENTRYPOINT ["/bin/bash", "-c", "/mytools/entrypoint.sh"]    