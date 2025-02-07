#!/usr/bin/perl
# Author:   Matthieu ACKERMANN <matthieu.ackermann@gmail.com>
# Date:     2020-06-16
# Version:  1.0
# Description: Custom script created for Zabbix monitoring (monitoring of processes specified in a file)
#              The source file is ./zabbix_agentd.conf.d/processes_to_monitor.txt
#              The configuration file contains 2 columns : process name to display, process name to search (into output of ps command)
#			   Make sure you have only one match with the name of the process to find

$param_file="/srv/zabbix-agent-IDS/etc/zabbix_agentd.conf.d/processes_to_monitor.txt";
$log_file="/var/log/zabbix/zabbix_agentd_IDS_processes.log";

$DEBUG=1;
@proclist = ();
@PROCLIST=`ps -eo cmd | grep -v process_discover | sort | uniq`;


log_debug("Start of the low level discovery of the processes to monitor");

open PARAM, $param_file or log_debug_and_die("Error opening the description file of processes $param_file");
while (<PARAM>) {
	chomp $_;
	@_ = split ';';
	if ($_[0] !~ /^#(.*)/){
		$proc_title = $_[0];
		$proc_name = $_[1];
	}
	$nb_proc = 0;
	foreach (@PROCLIST) {
		if (/$proc_name/) {
			chomp;
			++$nb_proc;
			log_debug("Found \"$proc_name\" ");
			log_debug("Full command line : $_");
		}
	}
	if ($nb_proc == 1) {
		log_debug( "\"$proc_name\" taken into account in the processes discovery");
		push @proclist, $proc_title;
	} else {
		log_debug( "\"$proc_name\" not taken into account in the processes discovery");
	}
}
close PARAM;

# Display in JSON format
$nb_proc = @proclist;
if ($nb_proc > 0) {
	print "{\n";
	print "  \"data\":[\n";
	$count = 0;
	foreach $proc (@proclist) {
		if ( $i > 0) {
			print " ,\n";
		}
		print "    { \"PROCESSNAME\":\"" . $proc . "\" }";
		++$i
	}
	print "\n  ]\n";
	print "}\n";
}
log_debug("End of the low level discovery of the processes to monitor");

# Functions
sub get_date {
    $date=`date "+%Y-%m-%d %H:%M:%S"`;
    chomp($date);
    return $date;
}

sub log_debug {
    $date=get_date();
    if ($DEBUG) {
        open DEBUG, ">> $log_file";
        print DEBUG "$date $_[0]\n";
        close DEBUG;
    }
}

sub log_debug_and_die {
    log_debug $_[0];
    die;
}

