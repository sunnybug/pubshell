#!/bin/bash

# ./install-gitlab.sh -u ip
# 访问http://ip:40080，用户名root，密码见本脚本的输出

while getopts ":u:" opt
do
    case $opt in
        u)
            echo "url:$OPTARG"
            SERVER_URL=$OPTARG
        ;;
        ?)
            echo "未知参数"
        exit 1;;
    esac
done

if [ -z "$SERVER_URL" ]
then
    echo "未提供-u选项参数"
    exit 1
fi



if [ "$EUID" -ne 0 ]; then
    echo "请使用root用户执行此脚本"
    exit
fi

if which docker >/dev/null; then
    echo "Docker is installed"
    echo "SERVER_URL:${SERVER_URL}"
else
    echo "Docker is not installed"
    exit 1;
fi

mkdir -p /data/gitlab/config
mkdir -p /data/gitlab/logs
mkdir -p /data/gitlab/data
docker pull gitlab/gitlab-ee:latest
SERVER_URL="${SERVER_URL}:40080"

docker run --detach \
--hostname $SERVER_URL \
--env GITLAB_OMNIBUS_CONFIG="external_url 'http://${SERVER_URL}';registry_external_url 'http://${SERVER_URL}' " \
--publish 40443:443 --publish 40080:80 --publish 40022:22 --publish 45050:5050 \
--name gitlab \
--restart always \
--volume /data/gitlab/config:/etc/gitlab \
--volume /data/gitlab/logs:/var/log/gitlab \
--volume /data/gitlab/data:/var/opt/gitlab \
--shm-size 256m \
gitlab/gitlab-ee:latest

url="http://${SERVER_URL}/users/sign_in"
echo "url=$url"

while true
do
    status=$(curl -s -o /dev/null -w '%{http_code}' "$url")
    
    if [ "$status" -eq 200 ]; then
        echo "The server is up and running."
        echo "User:root"
        echo "Password:"
        docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
        break
    else
        wait_time=3
        echo "The server is not yet ready. Waiting for $wait_time seconds..."
        sleep $wait_time
    fi
done