#!/bin/bash

set -euo pipefail

#
# NSS_WRAPPER
#

export HOME=/tmp/home
mkdir ${HOME}

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < passwd.template > /tmp/passwd

export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

function log {
    echo "$(date -Iseconds) $@"
}

#
# GPG Init
#

gpg --import /keys/gpg/privatekey.asc

function process_file {
    tmp=$(mktemp -u)
    gpg --output ${tmp} --decrypt $1
    cat ${tmp} | python formatter.py | sendemail -v \
            -s ${MAIL_SERVER} -o message-charset=utf-8 \
            -f fetch@${MAIL_DOMAIN} -t ${MAIL_RECIPIENT} -u "Lomake" -o tls=no
    rm ${tmp}
}

#
# SSH Opts
#

SSH_OPTS="-o StrictHostKeyChecking=no -i /keys/ssh/fetch" 
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"

WORK=/tmp/work
mkdir -p ${WORK}

last_miss_hour=""

while true
do
    # Check if there are files
    if [[ -z "$(ssh ${SSH_OPTS} ${REMOTE} \"find ${REMOTE_PATH}/ -type f\")" ]]; then
        # No files to be found, write a log message once per hour
        hour="$(date +%H)"
        if [[ "$hour" != "$last_miss_hour" ]]; then
            log "No files found (message silenced for this hour)"
        fi
        last_miss_hour="$hour"
    else
        log "Downloading queued files"
        scp ${SSH_OPTS} "${REMOTE}:${REMOTE_PATH}/*" ${WORK}

        for file in ${WORK}/*; do
            # Archive all the files
            cp ${file} /archive/

            log "Processing ${file}"
            process_file ${file}

            # Make sure that everything is fine so far and we have a file
            if [ -f /archive/$(basename ${file}) ]; then

                # Delete the temporary file locally
                rm ${file}

                # ... and remotely
                ssh ${SSH_OPTS} ${REMOTE} "rm ${REMOTE_PATH}/$(basename ${file})"
            else
                log "Something went wrong and we didn't get a file"
                exit 1
            fi
        done
    fi

    sleep 60
done
