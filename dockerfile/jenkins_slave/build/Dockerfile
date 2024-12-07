ARG gcc_ver=14
FROM 192.168.1.185:5000/devgcc14:241128

SHELL ["/bin/bash", "-c"]
COPY file/agent.jar /mytool/agent.jar
RUN apt update && apt install -y openjdk-17-jre

WORKDIR /root
# 不能放root下，因为root目录后面会被挂载出去
COPY file/entrypoint.sh /mytool/entrypoint.sh
RUN chmod +x /mytool/entrypoint.sh && rm -rf "/tmp/*"
ENTRYPOINT ["/bin/bash", "-c", "/mytool/entrypoint.sh"]    