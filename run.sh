#!/bin/bash

set -euo pipefail

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

while true
do
    ssh -i /keys/ssh/fetch ${REMOTE_USER}@${REMOTE_HOST} "ls -lah ${REMOTE_PATH}"
    sleep 5
done
