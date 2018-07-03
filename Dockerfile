FROM centos:7

RUN yum install -y gnupg2 openssh-clients

COPY . /fetch/
WORKDIR /fetch/

CMD [ "/bin/bash", "run.sh" ]
