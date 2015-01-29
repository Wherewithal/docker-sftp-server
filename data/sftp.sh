#!/bin/sh

set -e
set -o xtrace

SFTP_ROOT=/sftp
SFTP_LOG=/var/log/syslog

mkdir -p $SFTP_ROOT/data
mkdir -p $SFTP_ROOT/keys

chown -R wherewithal:sftpusers $SFTP_ROOT
chown root:sftpusers $SFTP_ROOT
chmod -R 750 $SFTP_ROOT

mkdir -p $SFTP_ROOT/dev

( umask 0 && truncate -s0 $SFTP_LOG )
tail --pid $$ -n0 -F $SFTP_LOG &

#/usr/sbin/rsyslogd

exec /usr/sbin/sshd -D
