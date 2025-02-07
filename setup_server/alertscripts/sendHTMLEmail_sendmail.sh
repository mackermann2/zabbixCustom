#!/bin/sh
export smtpemailfrom=My-Email-Notifications@domain.com
export zabbixemailto="$1"
export zabbixsubject="$2"
export zabbixbody="$3"
export smtpserver=smtp.domain.com
export smtplogin=login@domain
export smtppass=password
/usr/bin/sendEmail -f $smtpemailfrom -t $zabbixemailto -u $zabbixsubject \-m $zabbixbody -s $smtpserver:587  -o tls=no \-o message-content-type=html 
