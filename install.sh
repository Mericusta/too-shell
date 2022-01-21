#!/bin/bash

# 安装 make 命令
echo "NOTE: install command make"
sudo apt install make 

# check global.conf
GLOBAL_CONFIG=/home/mericustar/deploy/global.conf
if [ ! -f "$GLOBAL_CONFIG" ]; then
    echo "NOTE: $GLOBAL_CONFIG does not exist"
    exit
fi

# install directory
INSTALL_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^INSTALL_DIR/{print $2}'`
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir $INSTALL_DIR
fi

# download directory
DOWNLOAD_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^DOWNLOAD_DIR/{print $2}'`
if [ ! -d "$DOWNLOAD_DIR" ]; then
    mkdir $DOWNLOAD_DIR
fi

# go

cd $DOWNLOAD_DIR

GO_VERSION=`cat $GLOBAL_CONFIG | awk -F '=' '/^GO_VERSION/{print $2}'`
GO_INSTALLATION=go$GO_VERSION.linux-amd64.tar.gz
GO_INSTALL_DIRECTORY=$INSTALL_DIR/go
GO_PATH=`cat $GLOBAL_CONFIG | awk -F '=' '/^GO_PATH/{print $2}'`

if [ ! -d "$GO_INSTALL_DIRECTORY" ]; then
    echo "NOTE: tar $GO_INSTALLATION to $GO_INSTALL_DIRECTORY"
    # 解压安装包
    tar xzf $GO_INSTALLATION -C $INSTALL_DIR
    # 添加当前用户的环境变量
    echo "NOTE: add GOROOT, GOPATH to ~/.profile"
    echo "" >> ~/.profile
    echo "export GOROOT=$GO_INSTALL_DIRECTORY" >> ~/.profile
    echo "export GOPATH=$GO_PATH" >> ~/.profile
    echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.profile
    echo 'export PATH=$PATH:$GOPATH' >> ~/.profile
    echo -e "\033[34mNOTE: please execute command to add go path: source ~/.profile \033[0m"
    sleep 2
else
    echo "NOTE: $INSTALL_DIR/go already exists"
fi

# redis

cd $DOWNLOAD_DIR

REDIS_VERSION=`cat $GLOBAL_CONFIG | awk -F '=' '/^REDIS_VERSION/{print $2}'`
REDIS_INSTALLATION=redis-$REDIS_VERSION.tar.gz
REDIS_INSTALL_DIRECTORY=$INSTALL_DIR/redis-$REDIS_VERSION

if [ ! -d "$REDIS_INSTALL_DIRECTORY" ]; then
    echo "NOTE: tar $REDIS_INSTALLATION to $REDIS_INSTALL_DIRECTORY"
    # 解压安装包
    tar xzf $REDIS_INSTALLATION -C $INSTALL_DIR
    # 编译构建
    cd $REDIS_INSTALL_DIRECTORY
    echo $REDIS_INSTALL_DIRECTORY
    make
else
    echo "NOTE: $INSTALL_DIR/redis-$REDIS_VERSION already exists"
fi

# 验证是否安装成功
$REDIS_INSTALL_DIRECTORY/src/redis-server --version

# etcd

cd $DOWNLOAD_DIR

ETCD_VERSION=`cat $GLOBAL_CONFIG | awk -F '=' '/^ETCD_VERSION/{print $2}'`
ETCD_INSTALLATION=etcd-v$ETCD_VERSION-linux-amd64.tar.gz
ETCD_INSTALL_DIRECTORY=$INSTALL_DIR/etcd-v$ETCD_VERSION

if [ ! -d "$ETCD_INSTALL_DIRECTORY" ]; then
    echo "NOTE: tar $ETCD_INSTALLATION to $ETCD_INSTALL_DIRECTORY"
    # 创建文件夹
    mkdir $ETCD_INSTALL_DIRECTORY
    # 解压安装包
    tar xzf $ETCD_INSTALLATION -C $ETCD_INSTALL_DIRECTORY --strip-components=1
else
    echo "NOTE: $ETCD_INSTALL_DIRECTORY already exists"
fi

# 验证是否安装成功
$ETCD_INSTALL_DIRECTORY/etcd --version
ETCDCTL_API=3 $ETCD_INSTALL_DIRECTORY/etcdctl version