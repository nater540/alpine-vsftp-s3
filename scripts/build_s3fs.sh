#!/usr/bin/env bash

apk --no-cache add \
  linux-headers \
  libxml2-dev \
  build-base \
  automake \
  fuse-dev \
  autoconf \
  curl-dev

git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse && \
  cd /tmp/s3fs-fuse && \
  ./autogen.sh      && \
  ./configure       && \
  make -j 9         && \
  make install
