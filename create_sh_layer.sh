#!/bin/sh
set -ex

mkdir -pv ./bin ./lib64

# Copy the target binary
cp -v "$(which sh)" ./bin/

# The target is dynamic, copy the linux dynamic loader
cp -v /lib64/ld-linux-x86-64.so.2 ./lib64/

# Discover linked libraries, add them to the layer too
for lib in $(ldd ./bin/sh | awk '/=>/ {print $3}'); do
  cp -v "$lib" ./lib64/
done

# Create a (reproducible) tarball and save it's checksum
# `find | sort` and `tar -T -` maintain alphabetical file order
# Reset simple file attributes to predetermined constants.
LAYER_CHECKSUM="$(find ./bin ./lib -depth -print0 | sort -z \
  | tar -c -f - --owner=0 --group=0 --mtime='1970-01-01' -T - \
  | tee layer-1.tar | sha256sum | cut -d ' ' -f 1)"

sed -e "s/DIFF_ID/${LAYER_CHECKSUM}/" layer-1.json.in > layer-1.json

rm -rf \
  ./bin \
  ./lib64
