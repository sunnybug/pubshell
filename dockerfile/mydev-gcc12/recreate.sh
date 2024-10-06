#!/bin/bash
set -e

source $1
docker compose --env-file=$1 up -d
docker exec -it $CONTAINER_NAME bash -c 'if [ ! -d /root/.myshell ]; then curl -sSfL https://gitee.com/sunnybug/pubshell/raw/main/install/webinstall_pubshell.sh | bash; fi'