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
    # Test the connection
    ssh -o StrictHostKeyChecking=no -i /keys/ssh/fetch ${REMOTE_USER}@${REMOTE_HOST} "ls -lah ${REMOTE_PATH}"

    if scp -o StrictHostKeyChecking=no -i /keys/ssh/fetch "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/*" ${WORK}; then
        for file in ${WORK}/*; do
            cp $file /archive/
            if [ -f /archive/$(basename ${file}) ]; then
                rm $file
                ssh -o StrictHostKeyChecking=no -i /keys/ssh/fetch ${REMOTE_USER}@${REMOTE_HOST} "rm ${REMOTE_PATH}/$(basename ${file})"
            fi
        done
    else
        echo "No files found"
    fi

    sleep 60
done
