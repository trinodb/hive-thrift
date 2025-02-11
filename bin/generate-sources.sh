#!/bin/bash

set -eu

cd "${BASH_SOURCE%/*}/.."

TARGET=/build/target/generated-sources/thrift
GRADLE_VERSION=8.4
THRIFT_VERSION=$(mvn -q help:evaluate -Dexpression=libthrift.version -DforceStdout)

docker run -v "${PWD}:/build" --rm debian:bookworm /bin/sh -c "\
set -eux
apt-get update -q
apt-get install -q -y \
  ant \
  automake\
  bison \
  flex \
  g++ \
  git \
  libboost-all-dev \
  libevent-dev \
  libssl-dev \
  libtool \
  make \
  openjdk-17-jdk-headless \
  pkg-config \
  unzip \
  wget

wget https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -q \
  -O /tmp/gradle-$GRADLE_VERSION-bin.zip
unzip -d /tmp /tmp/gradle-$GRADLE_VERSION-bin.zip
mv /tmp/gradle-$GRADLE_VERSION /usr/local/gradle
ln -s /usr/local/gradle/bin/gradle /usr/local/bin

wget 'https://dlcdn.apache.org/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz'
tar zxf thrift-$THRIFT_VERSION.tar.gz
cd thrift-$THRIFT_VERSION
./bootstrap.sh
./configure --without-cpp --without-kotlin --without-python --without-py3
make
make install

rm -rf $TARGET
mkdir -p $TARGET
thrift -o $TARGET \
  --gen java:private_members,fullcamel,sorted_containers,generated_annotations=suppress \
  /build/src/main/thrift/hive_metastore.thrift
mv $TARGET/gen-java/io $TARGET
rmdir $TARGET/gen-java
chown -R $UID /build/target
"
