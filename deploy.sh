#!/bin/bash

# 配置文件
GLOBAL_CONFIG=/home/mericustar/global.conf
if [ ! -f $GLOBAL_CONFIG ]; then
    echo "NOTE: $GLOBAL_CONFIG does not exist"
    exit
fi

# -------------------------------- 系统级配置 --------------------------------

# 下载路径
DOWNLOADS_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^DOWNLOADS_DIR/{print $2}'`
if [ ! -d "$DOWNLOADS_DIR" ]; then
    mkdir $DOWNLOADS_DIR
fi

# 安装路径
INSTALL_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^INSTALL_DIR/{print $2}'`
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir $INSTALL_DIR
fi

# 配置路径
CONFIG_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^CONFIG_DIR/{print $2}'`
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir $CONFIG_DIR
fi

# 服务部署路径
DEPLOY_DIR=`cat $GLOBAL_CONFIG | awk -F '=' '/^DEPLOY_DIR/{print $2}'`
if [ ! -d "$DEPLOY_DIR" ]; then
    mkdir $DEPLOY_DIR
fi

# -------------------------------- 环境配置 --------------------------------

# redis

# 由于无法安装 build-essential 和 make，采用 apt install 的方式安装

# 使用 apt 安装 redis-server
sudo apt-get install redis-server

# 检查是否安装成功
redis-server --version