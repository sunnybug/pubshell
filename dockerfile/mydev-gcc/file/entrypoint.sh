#/bin/bash
echo 'entrypoint.sh begin .....'

# ssh
ss=$(service ssh status 2>&1)
if [[ ! $ss == *"is running"* ]]; then
    service ssh start
    echo "ssh start"
fi

# distcc
# ss=$(service distcc status 2>&1)
# if [[ ! $ss == *"is running"* ]]; then
#     service distcc start
#     echo "distcc start"
# fi

sh
echo 'entrypoint.sh end .....'
