#!/usr/bin/perl
#@fqdn = `cat /usr/lib/zabbix/externalscripts/ssl_fqdn_list.txt`;
@fqdn = `cat /usr/lib/zabbix/externalscripts/certs_to_check/TO_CHECK/ssl_fqdn_list.txt`;
$first = 1;

print "{\n";
print "  \"data\":[\n";
foreach (@fqdn) {

       @_ = split(':');
       print " ,\n" if not $first;
       $first = 0;

	   my $fqdn=$_[0];
	   my $port=$_[1];
	   $port=~s/\n//;

       print "    { ";
       print "\"FQDN\":\"$fqdn\",";
	   print "\"PORT\":\"$port\"";
       print " }";
}

print "\n  ]\n";
print "}\n"; 
