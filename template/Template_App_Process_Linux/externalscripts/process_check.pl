#!/usr/bin/perl

$param_file="/srv/zabbix-agent-IDS/etc/zabbix_agentd.conf.d/processes_to_monitor.txt";
$log_file="/var/log/zabbix/zabbix_agentd_IDS_processes.log";

$DEBUG=0;
$INTERVAL=1;
$PROC_TITLE=$ARGV[0];
$PROC_INFO=$ARGV[1];

log_debug("Start collecting information on the process \"$PROC_TITLE\" : $PROC_INFO");


open PARAM, $param_file or log_debug_and_die("Error opening the description file of processes $param_file");

LOOP:
while (<PARAM>) {
	chomp $_;
	@_ = split ';';
	$proc_title = $_[0];
	$PROC_NAME = $_[1];
	if ($proc_title eq $PROC_TITLE) {
		log_debug("Found $PROC_NAME for $proc_title");
		last LOOP;
	}
}
close PARAM;

# Check if the process name match with search criteria
@PROCLIST=`ps -eo pid,cmd | grep -v process_check | sort | uniq`;
$nb_proc = 0;
foreach (@PROCLIST) {
	if (/$PROC_NAME/) {
		chomp;
		log_debug("Full command line : $_");
		$pid=`ps hf -opid -C $PROC_NAME | awk '{ print \$1; exit }'`; # Command to get only parent PID in case of multiple processes 
		chomp($pid);
		log_debug("Found \"$PROC_NAME\", PID of master process to monitor : $pid");
	}
}

#if ($PROC_INFO eq "socket") {
#	# Need to give sudo root right on zabbix user to grant to execute lsof command
#	# zabbix ALL=(ALL) NOPASSWD: /usr/sbin/lsof
#	$socket=`sudo /usr/sbin/lsof -n -p $pid | grep ESTABLISHED | wc -l`;
#	chomp($socket);
#	log_debug("Found $socket socket(s) in ESTABLISHED state for \"$PROC_NAME\"");
#	print "$socket\n";
#}

if ($PROC_INFO eq "vmsize") {
	$vmsize=`grep VmSize /proc/$pid\/status | awk '{print \$2}'`;
	chomp($vmsize);
	$vmsize *= 1024;
	log_debug("Virtual memory consumption for \"$PROC_NAME\" : $vmsize Bytes");
	print "$vmsize\n";
}

if ($PROC_INFO eq "vmrss") {
	$vmrss=`grep VmRSS /proc/$pid/status | awk '{print \$2}'`;
	chomp($vmrss);
	$vmrss *= 1024;
	log_debug("Virtual memory resident size for \"$PROC_NAME\" : $vmrss Bytes");
	print "$vmrss\n";
}

# Get the total CPU time used from the boot 
sub get_cpu_time {
	$procstat=`head -1 /proc/stat`;
	chomp($procstat);
	$procstat =~ s/cpu *//;
	#print "$procstat\n";
	@procstat = split(/ /,$procstat);
	$totaltime = 0;
	foreach(@procstat) {
		$totaltime += $_;
	}
	return $totaltime;
}

# Get the number of CPU
sub get_cpu_number {
	$cpunum=`grep processor /proc/cpuinfo | wc -l`;
	return $cpunum;
}

# Ref for the meaning of certain fields of /proc 
# and calculation algorithmhmes of CPU %util
# http://man7.org/linux/man-pages/man5/proc.5.html
# http://stackoverflow.com/questions/1420426/calculating-cpu-usage-of-a-process-in-linux
# http://askubuntu.com/questions/120953/exact-field-meaning-of-proc-stat
# http://www.mjmwired.net/kernel/Documentation/filesystems/proc.txt

if ($PROC_INFO eq "cpu") {
	$cpu_count = get_cpu_number();
	$prev_totaltime = get_cpu_time();
	$prev_utime=`awk '{print \$14}' /proc/$pid/stat`;
	chomp($prev_utime);
	$prev_stime=`awk '{print \$15}' /proc/$pid/stat`;
	chomp($prev_stime);
	sleep $INTERVAL;
	$totaltime = get_cpu_time();
	$utime=`awk '{print \$14}' /proc/$pid/stat`;
	chomp($utime);
	$stime=`awk '{print \$15}' /proc/$pid/stat`;
	chomp($stime);
	$user_util=$cpu_count * 100 * ($utime - $prev_utime)/($totaltime - $prev_totaltime);
	$system_util=$cpu_count * 100 * ($stime - $prev_stime)/($totaltime - $prev_totaltime);
	$cpu_util = int($user_util + $system_util);
	log_debug("CPU consumption in percent (%) for \"$PROC_NAME\" : $cpu_util");
	print "$cpu_util\n";

}

# Get IO statistics
# Need to give sudo root right on zabbix user to grant to execute grep command in /proc/<pid>/io file
# zabbix ALL=(ALL) NOPASSWD: /bin/grep * /proc/*/io

if ($PROC_INFO eq "io_syscr") {
	$io_syscr=`sudo grep syscr /proc/$pid/io | awk '{print \$2}'`;
	chomp($io_syscr);
    log_debug("Number of read I/O operations for \"$PROC_NAME\" : $io_syscr");
    print "$io_syscr\n";
}
if ($PROC_INFO eq "io_syscw") {
    $io_syscw=`sudo grep syscw /proc/$pid/io | awk '{print \$2}'`;
    chomp($io_syscw);
    log_debug("Number of write I/O operations for \"$PROC_NAME\" : $io_syscw");
    print "$io_syscw\n";
}
if ($PROC_INFO eq "io_read_bytes") {
    $io_read_bytes=`sudo grep read_bytes /proc/$pid/io | awk '{print \$2}'`;
    chomp($io_read_bytes);
    log_debug("Number of bytes read for \"$PROC_NAME\" : $io_read_bytes");
    print "$io_read_bytes\n";
}
if ($PROC_INFO eq "io_write_bytes") {
    $io_write_bytes=`sudo grep ^write_bytes /proc/$pid/io | awk '{print \$2}'`;
    chomp($io_write_bytes);
    log_debug("Number of bytes written for \"$PROC_NAME\" : $io_write_bytes");
    print "$io_write_bytes\n";
}


log_debug("End of information collection on process \"$PROC_NAME\" : $PROC_INFO");

# Functions
sub get_date {
    $date=`date "+%Y-%m-%d %H:%M:%S"`;
    chomp($date);
    return $date;
}

sub log_debug {
    $date=get_date();
    if ($DEBUG) {
		#print $_[0]."\n";
        open DEBUG, ">> $log_file";
        print DEBUG "$date $_[0]\n";
        close DEBUG;
    }
}

sub log_debug_and_die {
    log_debug $_[0];
    die;
}
