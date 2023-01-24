#!/bin/bash

set -eux

cd "${BASH_SOURCE%/*}/.."

SOURCE_DIR=src/main/thrift
TARGET_DIR=target/generated-sources/thrift

rm -rf $TARGET_DIR
mkdir -p $TARGET_DIR

# use unstable for Thrift 0.17.0
docker run -v "${PWD}:/build" --rm debian:unstable /bin/sh -c "\
apt-get update -q && \
apt-get install -q -y thrift-compiler && \
thrift -o /build/${TARGET_DIR} -r \
  --gen java:private-members,fullcamel,generated_annotations=undated \
  /build/${SOURCE_DIR}/hive_metastore.thrift"

mv $TARGET_DIR/gen-java/io ${TARGET_DIR}
rmdir $TARGET_DIR/gen-java
