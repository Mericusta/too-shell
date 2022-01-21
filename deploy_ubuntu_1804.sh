#!/bin/bash

GO_VERSION=1.16
GO_DOWNLOAD_URL=https://studygolang.com/dl/golang

REDIS_VERSION=6.2.0
REDIS_DOWNLOAD_URL=http://download.redis.io/releases

ETCD_VERSION=3.3.15
ETCD_DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

GO111MODULE=off

while getopts v opt
do
    case $opt in
        v|--go)
            echo "NOTE: specify go version $OPTARG"
            GO_VERSION=$OPTARG
            ;;
        r|--redis)
            echo "NOTE: specify redis version $OPTARG"
            REDIS_VERSION=$OPTARG
            ;;
        e|--etcd)
            echo "NOTE: specify etcd version $OPTARG"
            ETCD_VERSION=$OPTARG
            ;;
        m|--gomod)
            echo "NOTE: specify env GO111MODULE=$OPTARG"
            GO111MODULE=$OPTARG
            ;;
        ?)
            echo "NOTE: unknown option"
            exit
    esac
done

# directory

cd ~/

mkdir -p documents downloads projects installation server

# sources

if [ ! -f "/etc/apt/sources.list" ]; then
    sudo mv /etc/apt/sources.list /etc/apt/sources.list

    sudo tee /etc/apt/sources.list <<< "
    deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    "

    sudo apt update && sudo apt upgrade
fi

# go

cd ~/downloads

GO_INSTALLATION=go$GO_VERSION.linux-amd64.tar.gz

if [ ! -f "$GO_INSTALLATION" ]; then
    wget $GO_DOWNLOAD_URL/$GO_INSTALLATION
else
    echo "NOTE: $GO_INSTALLATION already exists"
fi

if [ ! -d "/usr/local/go" ]; then
    tar -C /usr/local -xzf $GO_INSTALLATION
else
    echo "NOTE: go has been installed"
    echo "NOTE: `go version`"
fi

PROFILE=~/.profile

GOBIN=`cat $PROFILE | grep /usr/local/go/bin`
GOPATH=`cat $PROFILE | grep GOPATH`
GO111MODULE=`cat $PROFILE | grep GO111MODULE`

echo GOBIN=$GOBIN
echo GOPATH=$GOPATH
echo GO111MODULE=$GO111MODULE

if [ -z "$GOBIN" ] && [ -z "$GOPATH" ] && [ -z "$GO111MODULE" ]; then
    echo "" >> ~/.profile

    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile

    mkdir -p ~/projects/go
    echo "export GOPATH=~/projects/go" >> ~/.profile

    echo "export GO111MODULE=$GO111MODULE" >> ~/.profile
fi

cd ~/downloads

REDIS_INSTALLATION=redis-$REDIS_VERSION.tar.gz

if [ ! -f "$REDIS_INSTALLATION" ]; then
    wget $REDIS_DOWNLOAD_URL/$REDIS_INSTALLATION
else
    echo "NOTE: $REDIS_INSTALLATION already exists"
fi

# etcd

cd ~/downloads

ETCD_INSTALLATION=etcd-v$ETCD_VERSION-linux-amd64.tar.gz

if [ ! -f "$ETCD_INSTALLATION" ]; then
    wget $ETCD_DOWNLOAD_URL/v$ETCD_VERSION/$ETCD_INSTALLATION
else
    echo "NOTE: $ETCD_INSTALLATION already exists"
fi
