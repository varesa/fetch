FROM centos:7

RUN yum install -y gettext gnupg2 nss_wrapper openssh-clients

COPY . /fetch/
WORKDIR /fetch/

CMD [ "/bin/bash", "run.sh" ]
