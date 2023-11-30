#!/bin/bash

# 接続先情報
SSH_USER=user
SSH_PASS=password
SSH_HOST=your_ssh_server

if [ -n "$PASSWORD" ]; then
    sleep 3
    cat <<< "$PASSWORD"
    exit 0
fi

export PASSWORD=$SSH_PASS
export SSH_ASKPASS=$0

exec setsid -w ssh $SSH_USER@$SSH_HOST
