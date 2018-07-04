FROM centos:7

RUN yum install -y epel-release
RUN yum install -y gettext gnupg2 nss_wrapper openssh-clients

CMD [ "/bin/bash", "run.sh" ]

WORKDIR /fetch/
COPY . /fetch/

