FROM debian:12

####################################################################
#base 
EXPOSE 22/tcp

ENV TZ=Asia/Shanghai

COPY sources.list /etc/apt/sources.list
RUN echo '' > /etc/apt/sources.list.d/debian.sources
COPY preferences /etc/apt/preferences

RUN apt update\
    && apt install --no-install-recommends -y ssh p7zip-full python3.11-minimal python3-pip locales subversion git curl zsh sudo lua5.4\
    && pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/\
    && git config --global user.email "$USER@x.com"\
    && git config --global user.name "$USER"\
    && locale-gen en_US.UTF-8\
    && export LANG=en_US.UTF-8\
    && unlink /usr/bin/python ; link /usr/bin/python3 /usr/bin/python\
    && sed -i '/^PubkeyAcceptedAlgorithms/d;$aPubkeyAcceptedAlgorithms +ssh-rsa' /etc/ssh/sshd_config\
    && sed -i 's/\(^#\)\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config\
    && sed -i 's|\(^#\)\?MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config \
    && apt install --no-install-recommends -y gcc-12 g++-12 gdb make cmake ninja-build\
    && link /usr/bin/gcc-12 /usr/bin/gcc\
    && link /usr/bin/g++-12 /usr/bin/g++\
    && link /usr/bin/g++-12 /usr/bin/c++\
    && apt clean -y && apt autoclean -y && apt autoremove -y && bash -c 'rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'



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
COPY init.sh /mytools/init.sh
RUN chmod +x /mytools/init.sh
ENTRYPOINT ["sh", "-c", "/mytools/init.sh"]    