#!/usr/bin/perl
#@fqdn = `ls /usr/lib/zabbix/externalscripts/certs_to_check/`;
@fqdn = `find /usr/lib/zabbix/externalscripts/certs_to_check/TO_CHECK  -type f -regextype posix-egrep -regex ".*cer|.*pem"`;
$first = 1;

print "{\n";
print "  \"data\":[\n";
foreach (@fqdn) {

       @_ = split(' ');
       print " ,\n" if not $first;
       $first = 0;

       print "    { ";
       print "\"CERTIFICATE_FILE\":\"$_[0]\"";
       print " }";
}

print "\n  ]\n";
print "}\n"; 
