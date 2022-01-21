#!/bin/bash 

scp protobuf/* $1:/remoteProto

ssh $1 << remotessh

cd /home/dev/protoc
/bin/bash remoteProtoGen.sh
exit

remotessh

scp -r $1:/remoteOutProto .
cp -r remoteOutProto/* $GOPATH/