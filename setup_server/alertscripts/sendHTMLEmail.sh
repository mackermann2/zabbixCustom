#!/bin/bash
SSL_verify_mode=SSL_VERIFY_NONE
MAIL_BIN=/bin/sendEmail
to=$1
subject=$2
body=$3
timestamp=$(date "+%s");
tempfile=/tmp/zabbix$timestamp\.html

echo $body > $tempfile

#echo $body | $MAIL_BIN -s "$(echo -e "$subject\nX-Priority: 1\nContent-Type: text/html")" -r "My-Email-Notifications@domain.com" $to 2>&1 
$MAIL_BIN -s smtp.mydomain.com:25 -xu login@domain -xp password -f "My-Email-Notifications@domain.com" -u "$subject" -t "$to" -o message-content-type=html -o message-header="X-Priority: 1" -o message-file=$tempfile

#cat <<EOF | mail -s "$subject" "$to"
#$body
#EOF
