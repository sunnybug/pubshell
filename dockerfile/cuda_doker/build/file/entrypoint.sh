#/bin/bash
echo 'entrypoint.sh begin .....'

# ssh
ss=$(service ssh status 2>&1)
if [[ ! $ss == *"is running"* ]]; then
    service ssh start
    echo "ssh start"
fi

sh
echo 'entrypoint.sh end .....'
