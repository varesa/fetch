#!/bin/bash

set -euo pipefail

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

HOME=/tmp/home
mkdir -p ${HOME}

WORK=$HOME/work
mkdir -p ${WORK}

while true
do
    ssh -o StrictHostKeyChecking=no -i /keys/ssh/fetch ${REMOTE_USER}@${REMOTE_HOST} "ls -lah ${REMOTE_PATH}"
    scp -o StrictHostKeyChecking=no -i /keys/ssh/fetch "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/*" ${WORK}

    for file in ${WORK}/*; do
        echo $file
    done
    sleep 5
done
