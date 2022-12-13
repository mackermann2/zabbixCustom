#!/bin/sh
export smtpemailfrom=IM-IT-IS-Notifications@saint-gobain.com
export zabbixemailto="$1"
export zabbixsubject="$2"
export zabbixbody="$3"
export smtpserver=smtpauth.mail.saint-gobain.net
export smtplogin=CFRsvc-Notifications@za
export smtppass=Nys3q6dS
/usr/bin/sendEmail -f $smtpemailfrom -t $zabbixemailto -u $zabbixsubject \-m $zabbixbody -s $smtpserver:587  -o tls=no \-o message-content-type=html 
