#!/usr/bin/env bash

mkdir -p ${BUCKET_MOUNT_DIR}

# Create the vsftpd account that users will be permitted to log into
addgroup -g 1000 ${FTP_GROUPNAME} && \
  adduser -D -u 1000 -G ${FTP_GROUPNAME} -h ${BUCKET_MOUNT_DIR} -s /sbin/nologin ${FTP_USERNAME}

# Add the newly created local account to the vsftpd userlist
echo "${FTP_USERNAME}" > /etc/vsftpd.userlist

# Set the password on the local account
echo "${FTP_USERNAME}:${FTP_PASSWORD}" | chpasswd

# Store the AWS credentials in the s3fs file & set appropriate permissions
echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

apk --no-cache add \
  libstdc++ \
  openssl \
  libxml2 \
  vsftpd \
  fuse \
  git \
  wget

# ln -sf /dev/stdout /var/log/vsftpd.log

# Install dumb-init as our process supervisor
wget --quiet -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
chmod +x /usr/local/bin/dumb-init

# Generate a self signed cert for vsftpd
openssl req -x509 -nodes -days 3600 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/private/vsftpd.pem -subj "/C=US/ST=${CERT_STATE}/O=${CERT_ORG}"
