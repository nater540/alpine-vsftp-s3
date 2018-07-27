#!/usr/bin/env bash

/usr/local/bin/s3fs -o allow_other ${AWS_S3BUCKET} ${BUCKET_MOUNT_DIR}

mkdir -p /var/log/vsftpd && \
  touch /var/log/vsftpd/vsftpd.log

echo "**************************************************"
echo "VSFTPd Running!"
echo "**************************************************"
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
