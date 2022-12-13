#!/bin/bash
# Author:       Matthieu ACKERMANN
# Date:         18/10/2019
# Description:  Backup script with Borg utility 
# Remark:     

if [[ $# -eq 0 ]] ; then
    echo Usage: 
	echo $0 '</path/to/borg/repository> </path1/to/save> </path2/to/save> </path3/to/save>'
    exit 0
fi

set -e
BORG_REPO=$(echo $1 | sed -e 's/\/$//')
BORG_REPO_NAME=$(echo $BORG_REPO | /bin/awk -F'/' '{print $NF}')
export BORG_PASSPHRASE='Z@bbXids2k19!'
BORG_ARCHIVE=$BORG_REPO::`hostname`-$BORG_REPO_NAME-{now:%Y-%m-%d}
PATH_TO_SAVE=$(echo "${@:2}")
LOG_FILE=$BORG_REPO/status.txt


# Archive creation
borg create \
-v --stats --compression lz4 \
$BORG_ARCHIVE \
$PATH_TO_SAVE \
> ${LOG_FILE} 2>&1

# Status log file 
#borg info $BORG_ARCHIVE >> ${LOG_FILE} 2>&1 
borg check -v $BORG_REPO >> ${LOG_FILE} 2>&1
 
# Cleanup of old backups. We keep : 
# - one archive per day for the last 7 days 
# - one archive by week for the last 4 weeks
# - one archive per month for the last 6 months

borg prune -v $BORG_REPO \
--keep-daily=7 \
--keep-weekly=4 \
--keep-monthly=6 \
>> ${LOG_FILE} 2>&1

