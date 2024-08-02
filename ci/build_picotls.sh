#!/bin/sh -e
# build picotls (for GitHub workflow)

if [ "${OPENSSL}" = "openssl1" ]; then
    WORKSPACE=picotls-openssl1
elif [ "${OPENSSL}" = "openssl3" ]; then
    WORKSPACE=picotls-openssl3
else
    WORKSPACE=picotls-libressl
fi

mkdir "${WORKSPACE}"
cd "${WORKSPACE}"
git init
git remote add origin https://github.com/nak3/picotls
git fetch origin --depth 1 "6f3bfe4b4ddcedfcdeed90888b4f07141ed3b641"
git checkout "6f3bfe4b4ddcedfcdeed90888b4f07141ed3b641"
git submodule update --init --depth 1
if [ "${OPENSSL}" = "openssl1" ]; then
    PKG_CONFIG_PATH=$PWD/../openssl1/build/lib/pkgconfig
elif [ "${OPENSSL}" = "openssl3" ]; then
    PKG_CONFIG_PATH=$PWD/../openssl3/build/lib/pkgconfig:$PWD/../openssl3/build/lib64/pkgconfig
else
    PKG_CONFIG_PATH=$PWD/../libressl/build/lib/pkgconfig:$PWD/../libressl/build/lib/pkgconfig
fi

export PKG_CONFIG_PATH

cmake -B build -DCMAKE_POSITION_INDEPENDENT_CODE=ON

make -j"$(nproc 2> /dev/null || sysctl -n hw.ncpu)" -C build
