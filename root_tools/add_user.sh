#!/bin/bash
PASSWORD=""
USERNAME=""

function GetAccount()
{
    MIN_LENGTH=13
    MAX_LENGTH=20
    CHARACTERS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{}|;:,.<>?/~"

    LENGTH=$(($RANDOM % ($MAX_LENGTH - $MIN_LENGTH + 1) + $MIN_LENGTH))

    for ((i = 0; i < LENGTH; i++)); do
        PASSWORD+="${CHARACTERS:$RANDOM % ${#CHARACTERS}:1}"
    done

    read -p "输入创建用户的名字: " mUN
    if [ -z "$mUN" ]; then
        echo "用户名不能为空"
        exit 2
    fi
    PASSWORD="hot123456"
    USERNAME=$mUN
}

function CreateUser()
{
    useradd -m $USERNAME
    echo $USERNAME
    if [ $? -ne 0 ]; then
        echo "创建用户 $USERNAME 失败。"
        exit 2
    fi

    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    if [ $? -ne 0 ]; then
        echo "设置密码失败。"
        exit 3
    fi
}

function SetUserPermission()
{
    FILENAME="/etc/sudoers.d/$USERNAME"
    #FILENAME="/root/pubshell/root_tools/$USERNAME"
    # 准备要写入的sudoers规则
    SUDOERS_ENTRY="Cmnd_Alias SVR_CMD =  /bin/apt,/usr/bin/docker,/usr/bin/rm"
    SUDOERS_RULE="$USERNAME ALL=(ALL) NOPASSWD: SVR_CMD"

    # 写入sudoers文件的两行内容
    echo "$SUDOERS_ENTRY" | sudo tee -a "$FILENAME" > /dev/null
    echo "$SUDOERS_RULE" | sudo tee -a "$FILENAME" > /dev/null


    # 检查写入是否成功
    if [ $? -eq 0 ]; then
        echo "为用户 $USERNAME 写入sudoers规则成功。"
    else
        echo "为用户 $USERNAME 写入sudoers规则失败。"
        exit 2
    fi
}

function CreateCredentials()
{
    CURRENT_USER=$(whoami)
    TARGET_USER=$USERNAME

    # 目标用户的主目录
    HOME_DIR=$(getent passwd "$TARGET_USER" | cut -d: -f6)

    # 创建.ssh目录并设置权限
    mkdir -p "$HOME_DIR/.ssh"
    chmod 700 "$HOME_DIR/.ssh"

    # 生成SSH密钥对
    ssh-keygen -t rsa -b 4096 -f "$HOME_DIR/.ssh/id_rsa" -q -N "" -C "$TARGET_USER"

    # 检查密钥是否成功生成
    if [ $? -eq 0 ]; then
        echo "为用户 $TARGET_USER 生成SSH密钥对成功。"
        chmod 600 "$HOME_DIR/.ssh/id_rsa"
        chmod 644 "$HOME_DIR/.ssh/id_rsa.pub"
        cp "$HOME_DIR/.ssh/id_rsa.pub" "$HOME_DIR/.ssh/authorized_keys"

        chown -R $USERNAME "$HOME_DIR/.ssh/"
    else
        echo "为用户 $TARGET_USER 生成SSH密钥对失败。"
        exit 4
    fi
    # cat id_rsa.pub >> authorized_keys
    # 输出公钥路径
    echo "公钥路径: $HOME_DIR/.ssh/id_rsa.pub"
}

GetAccount
CreateUser
SetUserPermission
CreateCredentials
