#!/bin/sh
#
# This script is used to compile your program on CodeCrafters
#
# This runs before .codecrafters/run.sh
#
# Learn more: https://codecrafters.io/program-interface

set -e # Exit on failure
uname -a
OLDPWD="$(pwd)"
echo "$OLDPWD"

curl -L -o /tmp/nasm-3.01.tar.xz https://www.nasm.us/pub/nasm/releasebuilds/3.01/nasm-3.01.tar.xz && \
mkdir -p /tmp/nasm-build && cd /tmp/nasm-build && \
tar -xf /tmp/nasm-3.01.tar.xz && cd nasm-3.01 && \
./configure --prefix="$HOME/.local" && make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)" && make install && \
export PATH="$HOME/.local/bin:$PATH" && nasm --version

echo "$OLDPWD"

cd "$OLDPWD"
cd /app

cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake
cmake --build ./build
