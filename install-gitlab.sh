#!/bin/bash

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

export GITLAB_HOME=/data/gitlab

if [ "$EUID" -ne 0 ]; then
  echo "请使用root用户执行此脚本"
  exit
fi

if which docker >/dev/null; then
  echo "Docker is installed"
  echo "SERVER_URL:${SERVER_URL}"
  echo "GITLAB_HOME:${GITLAB_HOME}"
else
  echo "Docker is not installed"
  exit 1;
fi

useradd docker-gitlab-user -u 1500 --shell /usr/sbin/nologin

mkdir -p $GITLAB_HOME/config
mkdir -p $GITLAB_HOME/logs
mkdir -p $GITLAB_HOME/data

chown -R docker-gitlab-user:docker-gitlab-user /data/gitlab

docker pull gitlab/gitlab-ee:latest
docker run --detach \
  --user 1500 \
  --hostname $SERVER_URL \
  --publish 10443:443 --publish 10080:80 --publish 10022:22 --publish 15050:5050 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ee:latest

sudo sed -i "$ a registry_external_url \"${SERVER_URL}:5050\"" /data/gitlab/config/gitlab.rb

docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
