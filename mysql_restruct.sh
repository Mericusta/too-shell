#!/bin/bash

MYQSL_HOSTNAME=192.168.1.11
MYSQL_USERNAME=dev
MYSQL_PASSWORD=dev123
MYSQL_DUMP_DATABASE=cof_cn_dlc
MYSQL_RESTRUCT_DATABASE=liyunpeng_dev
DATE="`date +%Y_%m_%d`"

# dump database struct sql
mysqldump -h$MYQSL_HOSTNAME -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -d $MYSQL_DUMP_DATABASE > dump_cof_cn_dlc_$DATE.sql

echo "drop database if exists $MYSQL_RESTRUCT_DATABASE;\\ncreate database $MYSQL_RESTRUCT_DATABASE;" > drop_${MYSQL_RESTRUCT_DATABASE}_$DATE.sql
# drop database by sql file
mysql -h$MYQSL_HOSTNAME -u$MYSQL_USERNAME -p$MYSQL_PASSWORD < drop_${MYSQL_RESTRUCT_DATABASE}_$DATE.sql

# restruct database by sql file
mysql -h$MYQSL_HOSTNAME -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $MYSQL_RESTRUCT_DATABASE < dump_cof_cn_dlc_$DATE.sql