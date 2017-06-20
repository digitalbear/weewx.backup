#!/bin/bash

echo '-------------------------------------------------'
echo `date` - start weewx db backup

export PATH=/home/weewx/backup:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

WEEWX_DB=/home/weewx/archive/weewx.sdb
TODAY=`date +"%Y-%m-%d"`
DUMP_FILE=/home/weewx/backup/weewx.dump.$TODAY.gz
S3_BUCKET=s3://dubweather-backup

echo 'stop the weewx daemon and wait 30 seconds'
service weewx stop
retn_code=$?
if [ $retn_code -ne 0 ]; then
  exit 7
fi

sleep 30s

echo 'dump sqlite3 database'
echo '.dump' | sqlite3 $WEEWX_DB | gzip -c > $DUMP_FILE

echo 'restart the weewx daemon'
service weewx start

# call script to manage daily/weekly/monthly/annual archiving to S3
s3_archive.sh $DUMP_FILE $S3_BUCKET

retn_code=$?
if [ $retn_code -eq 0 ]; then
  echo 'dump successfully copied to S3 - deleting from local'
  rm -f $DUMP_FILE
fi

echo `date` - end weewx db backup
echo '-------------------------------------------------'
