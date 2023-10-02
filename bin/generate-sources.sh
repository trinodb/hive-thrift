#!/bin/bash

set -eu

cd "${BASH_SOURCE%/*}/.."

TARGET=/build/target/generated-sources/thrift

# use unstable for Thrift 0.19.0
docker run -v "${PWD}:/build" --rm debian:unstable /bin/sh -c "\
set -eux
apt-get update -q
apt-get install -q -y thrift-compiler
rm -rf $TARGET
mkdir -p $TARGET
thrift -o $TARGET \
  --gen java:private_members,fullcamel,sorted_containers,generated_annotations=suppress \
  /build/src/main/thrift/hive_metastore.thrift
mv $TARGET/gen-java/io $TARGET
rmdir $TARGET/gen-java
chown -R $UID /build/target
"
