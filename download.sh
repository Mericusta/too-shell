#!/bin/bash

USE_SCP=0
while getopts s opt
do
    case $opt in
        s)
            echo "NOTE: download by scp"
            USE_SCP=1
            ;;
        ?)
            echo "NOTE: unknown option"
            exit
    esac
done

# check global.conf
GLOBAL_CONFIG=/home/mericustar/deploy/global.conf
if [ ! -f "$GLOBAL_CONFIG" ]; then
    echo "NOTE: $GLOBAL_CONFIG does not exist"
    exit
fi

# scp info
SCP_USERNAME=`cat $GLOBAL_CONFIG | awk -F '=' '/^SCP_USERNAME/{print $2}'`
SCP_HOST=`cat $GLOBAL_CONFIG | awk -F '=' '/^SCP_HOST/{print $2}'`
SCP_REMOTE_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^SCP_REMOTE_DIR/{print $2}'`

# download directory
DOWNLOAD_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^DOWNLOAD_DIR/{print $2}'`
if [ ! -d "$DOWNLOAD_DIR" ]; then
    mkdir $DOWNLOAD_DIR
fi
cd $DOWNLOAD_DIR

# go

GO_VERSION=`cat $GLOBAL_CONFIG | awk -F '=' '/^GO_VERSION/{print $2}'`
GO_INSTALLATION=go$GO_VERSION.linux-amd64.tar.gz
GO_DOWNLOAD_URL=https://gomirrors.org/dl/go/$GO_INSTALLATION

# 检查本地是否已经下载 go 包
if [ ! -f "$GO_INSTALLATION" ]; then
    if [ $USE_SCP -eq 0 ]; then
        echo "NOTE: downloading $GO_INSTALLATION from $GO_DOWNLOAD_URL"
        # wget $GO_DOWNLOAD_URL
    else
        echo "NOTE: downloading $GO_INSTALLATION from $SCP_HOST:$SCP_REMOTE_DIR by scp"
        # TODO: 想办法检查文件是否存在
        scp $SCP_USERNAME@$SCP_HOST:$SCP_REMOTE_DIR/$GO_INSTALLATION .
    fi
else
    echo "NOTE: $GO_INSTALLATION already exists"
fi

# redis

REDIS_VERSION=`cat $GLOBAL_CONFIG | awk -F '=' '/^REDIS_VERSION/{print $2}'`
REDIS_INSTALLATION=redis-$REDIS_VERSION.tar.gz
REDIS_DOWNLOAD_URL=http://download.redis.io/releases/$REDIS_INSTALLATION

# 检查本地是否已下载 redis 包
if [ ! -f "$REDIS_INSTALLATION" ]; then
    if [ $USE_SCP -eq 0 ]; then
        echo "NOTE: downloading $REDIS_INSTALLATION from $REDIS_DOWNLOAD_URL"
        # wget $REDIS_DOWNLOAD_URL
    else
        echo "NOTE: downloading $REDIS_INSTALLATION from $SCP_HOST:$SCP_REMOTE_DIR by scp"
        # TODO: 想办法检查文件是否存在
        scp $SCP_USERNAME@$SCP_HOST:$SCP_REMOTE_DIR/$REDIS_INSTALLATION .
    fi
else
    echo "NOTE: $REDIS_INSTALLATION already exists"
fi

# etcd

ETCD_VERSION=`cat $GLOBAL_CONFIG | awk -F '=' '/^ETCD_VERSION/{print $2}'`
ETCD_INSTALLATION=etcd-v$ETCD_VERSION-linux-amd64.tar.gz
ETCD_DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

# 检查本地是否已下载 etcd 包
if [ ! -f "$ETCD_INSTALLATION" ]; then
    if [ $USE_SCP -eq 0 ]; then
        echo "NOTE: downloading $ETCD_INSTALLATION from $ETCD_DOWNLOAD_URL"
        # wget $ETCD_DOWNLOAD_URL/v$ETCD_VERSION/$ETCD_INSTALLATION
    else
        echo "NOTE: downloading $ETCD_INSTALLATION from $SCP_HOST:$SCP_REMOTE_DIR by scp"
        # TODO: 想办法检查文件是否存在
        scp $SCP_USERNAME@$SCP_HOST:$SCP_REMOTE_DIR/$ETCD_INSTALLATION .
    fi
else
    echo "NOTE: $ETCD_INSTALLATION already exists"
fi
