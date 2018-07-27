######################################################################
# Create the base container that we'll use to build all of the stages.
######################################################################
FROM alpine:3.8 AS base
LABEL maintainer="Nate Strandberg <nater540@gmail.com>"

ARG FTP_GROUPNAME=ftpuser
ARG FTP_USERNAME=ftpuser
ARG FTP_PASSWORD

ARG AWS_S3BUCKET
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ARG CERT_STATE=Connecticut
ARG CERT_ORG=None

ENV AWS_S3BUCKET=${AWS_S3BUCKET}
ENV BUCKET_MOUNT_DIR=/home/${FTP_USERNAME}/${AWS_S3BUCKET}

RUN \
  : "${FTP_GROUPNAME:?Build argument needs to be set and non-empty.}"         && \
  : "${FTP_USERNAME:?Build argument needs to be set and non-empty.}"          && \
  : "${FTP_PASSWORD:?Build argument needs to be set and non-empty.}"          && \
  : "${AWS_S3BUCKET:?Build argument needs to be set and non-empty.}"          && \
  : "${AWS_ACCESS_KEY_ID:?Build argument needs to be set and non-empty.}"     && \
  : "${AWS_SECRET_ACCESS_KEY:?Build argument needs to be set and non-empty.}" && \
  : "${CERT_STATE:?Build argument needs to be set and non-empty.}"            && \
  : "${CERT_ORG:?Build argument needs to be set and non-empty.}"

COPY ./scripts /scripts

RUN apk --no-cache add bash && \
  /scripts/base_packages.sh

######################################################################
# Create a separate stage for building s3fs.
######################################################################
FROM base AS s3fs-build

RUN /scripts/build_s3fs.sh

######################################################################
# Create the final destination stage.
######################################################################
FROM base AS final-destination

COPY --from=s3fs-build /usr/local/bin/s3fs /usr/local/bin/s3fs
COPY ./vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./bootstrap.sh /bootstrap.sh

# Use "dumb-init" as our process manager
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/bootstrap.sh"]
