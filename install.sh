#!/bin/sh

set -e

VER=$1

if [ $(arch) == "aarch64" ]; 
  then ARCH=arm64
elif [ $(arch) == "x86_64" ];
  then ARCH=amd64
fi

mkdir -p /usr/src

# Download release
curl -L https://github.com/ansible-semaphore/semaphore/releases/download/v${VER}/semaphore_${VER}_linux_${ARCH}.tar.gz > \
/usr/src/semaphore_${VER}_linux_${ARCH}.tar.gz

cd /usr/src
tar xzf /usr/src/semaphore_${VER}_linux_${ARCH}.tar.gz

# Move to /usr/local/bin
mv /usr/src/semaphore /usr/local/bin/semaphore

# Clear out the download
rm -Rf ./*
