#!/bin/bash

SRC=$1

echo "git clone $SRC"

# https://github.com/x1/x2/xn/end.git

REPLACE_SRC=$(echo $SRC | sed 's/github.com/github.com.cnpmjs.org/')

HTTPS_GITHUB="https://github.com/"

S1=${SRC##$HTTPS_GITHUB}

RES_DIR=${S1%/*}

echo "mkdir -p $GOPATH/src/github.com/$RES_DIR"

mkdir -p $GOPATH/src/github.com/$RES_DIR

echo "cd $GOPATH/src/github.com/$RES_DIR"

cd $GOPATH/src/github.com/$RES_DIR

echo "git clone $REPLACE_SRC"

git clone $REPLACE_SRC