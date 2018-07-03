#!/bin/bash

set -euo pipefail

while true
do
    ssh -i /keys/ssh/fetch ${REMOTE_USER}@${REMOTE_HOST} "ls -lah ${REMOTE_PATH}"
    sleep 5
done
