#!/bin/bash

set -eu

cd "${BASH_SOURCE%/*}/.."

TARGET=/build/target/generated-sources/thrift

# use the latest Thrift compiler
docker run -v "${PWD}:/build" --rm debian /bin/sh -c "\
set -eux
echo 'deb http://deb.debian.org/debian experimental main' > /etc/apt/sources.list.d/experimental.list
apt-get update -q
apt-get install -q -y thrift-compiler/experimental
rm -rf $TARGET
mkdir -p $TARGET
thrift -o $TARGET \
  --gen java:private_members,fullcamel,sorted_containers,generated_annotations=suppress \
  /build/src/main/thrift/hive_metastore.thrift
mv $TARGET/gen-java/io $TARGET
rmdir $TARGET/gen-java
chown -R $UID /build/target
"
