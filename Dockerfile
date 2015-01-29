FROM phusion/baseimage:0.9.15
CMD ["/sbin/my_init"]

MAINTAINER Ho-Sheng Hsiao <hosh@getwherewithal.com>

# RUN sed -i 's/trusty/vivid/g' /etc/apt/sources.list
# RUN echo nameserver 8.8.8.8 > /etc/resolv.conf
RUN apt-get update && apt-get install -y openssh-server
# phusion/baseimage already has this
# RUN mkdir /var/run/sshd
RUN groupadd sftpusers
RUN useradd --shell /sbin/nologin --home-dir /sftp --no-create-home -G sftpusers wherewithal
RUN mkdir -p /sftp

# Custom sshd_config to run different organizations
ADD ./data/sshd_config /etc/ssh/sshd_config
ADD ./data/readme.txt  /sftp/readme.txt
#ADD ./data/sshd.conf   /etc/rsyslog.d/sshd.conf

RUN mkdir -p /etc/service/openssh
ADD ./data/sftp.sh     /etc/service/openssh/run
RUN chmod +x /etc/service/openssh/run

RUN mkdir -p /opt/bin
ADD ./data/get-keys.sh /opt/bin/get-keys.sh
RUN chmod +x /opt/bin/get-keys.sh

VOLUME /etc
VOLUME /sftp

EXPOSE 22
