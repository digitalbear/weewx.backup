#!/bin/bash

echo '-------------------------------------------------'
echo `date` - start S3 archive

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

BACKUP_FILE=$1
S3_BUCKET=$2
retn_code=0

echo 'copy ' $BACKUP_FILE ' to S3 daily bucket ' $S3_BUCKET
s3cmd put $BACKUP_FILE $S3_BUCKET/daily/

if [ $? -eq 0 ]; then
  echo 'remove daily backups from S3 more than 1 week old'
  s3cmd ls $S3_BUCKET/daily/weewx* | awk '$4 != "$S3_BUCKET/daily/"' | awk '$1 < "'$(date +%F -d '1 week ago')'" {print $4;}' | xargs --no-run-if-empty s3cmd del
else
  retn_code=1
fi

###################################
# take weekly backup every Sunday #
###################################
if [ `date +%w` == "0" ]; then

  echo 'copy ' $BACKUP_FILE ' to S3 weekly bucket'
  s3cmd put $BACKUP_FILE $S3_BUCKET/weekly/

  if [ $? -eq 0 ]; then
    echo 'remove weekly backups from S3 more than 1 month old'
    s3cmd ls $S3_BUCKET/weekly/weewx* | awk '$4 != "$S3_BUCKET/weekly/"' | awk '$1 < "'$(date +%F -d '1 month ago')'" {print $4;}' | xargs --no-run-if-empty s3cmd del
  else
    retn_code=1
  fi

fi

#################################################
# take monthly backup on the 1st of every month #
#################################################
if [ `date +%d` == "01" ]; then

  echo 'copy ' $BACKUP_FILE ' to S3 monthly bucket'
  s3cmd put $BACKUP_FILE $S3_BUCKET/monthly/

  if [ $? -eq 0 ]; then
    echo 'remove monthly backups from S3 more than 1 year old'
#    s3cmd ls $S3_BUCKET/monthly/weewx* | awk '$4 != "$S3_BUCKET/monthly/"' | awk '$1 < "'$(date +%F -d '1 year ago')'" {print $4;}' | xargs --no-run-if-empty s3cmd del
  else
    retn_code=1
  fi

fi

############################################
# take annual backup on the 1st of January #
############################################
if [ `date +%m%d` == "0101" ]; then

  echo 'copy ' $BACKUP_FILE ' to S3 annual bucket'
  s3cmd put $BACKUP_FILE $S3_BUCKET/annual/

  if [ $? -ne 0 ]; then
    retn_code=1
  fi
fi

echo `date` - end S3 archive
echo '-------------------------------------------------'

exit $retn_code
