#!/bin/bash
borg_discover(){
	dirname $(grep -silm1 "This is a Borg Backup repository." /data/backup/borg/*/README) | awk 'BEGIN{printf "{\"data\":["}; {i=split($1,path,"/"); printf c"{\"{#PATH}\":\""$1"\", \"{#HOST}\":\"" path[i-1] "\", \"{#DIR}\":\"" path[i] "\"}";c="," };  END{print "]}"}'
}

borg_start_time(){
	date -d "$(grep -i "time (start)" $1/status.txt | sed 's/^.*): //;s/$//')"
}

borg_start_timestamp(){
	date -d "$(grep -i "time (start)" $1/status.txt | sed 's/^.*): //;s/$//')" +%s
}

borg_end_time(){
	date -d "$(grep -i "time (end)" $1/status.txt | sed 's/^.*): //;s/$//')"
}

borg_end_timestamp(){
	date -d "$(grep -i "time (end)" $1/status.txt | sed 's/^.*): //;s/$//')" +%s
}

borg_all_original(){
	grep -i "All archives" $1/status.txt | awk '$4~/^TB/{printf "%.f", $3*1000*1000*1000*1000}; $4~/^GB/{printf "%.f", $3*1000*1000*1000}; $4~/^MB/{printf "%u", $3*1000*1000}; $4~/^kB/{printf "%u", $3*1000}; $4~/^B/{print $3};'
}

borg_all_compressed(){
	grep -i "all archives" $1/status.txt | awk '$6~/^TB/{printf "%.f", $5*1000*1000*1000*1000}; $6~/^GB/{printf "%.f", $5*1000*1000*1000}; $6~/^MB/{printf "%u", $5*1000*1000}; $6~/^kB/{printf "%u", $5*1000}; $6~/^B/{print $5};'
}

borg_all_deduplicated(){
	grep -i "all archives" $1/status.txt | awk '$8~/^TB/{printf "%.f", $7*1000*1000*1000*1000}; $8~/^GB/{printf "%.f", $7*1000*1000*1000}; $8~/^MB/{printf "%u", $7*1000*1000}; $8~/^kB/{printf "%u", $7*1000}; $8~/^B/{print $7};'
}

borg_this_original(){
	grep -i "this archive" $1/status.txt | awk '$4~/^TB/{printf "%.f", $3*1000*1000*1000*1000}; $4~/^GB/{printf "%.f", $3*1000*1000*1000}; $4~/^MB/{printf "%u", $3*1000*1000}; $4~/^kB/{printf "%u", $3*1000};$4~/^B/{print $3};'
}

borg_this_compressed(){
	grep -i "this archive" $1/status.txt | awk '$6~/^TB/{printf "%.f", $5*1000*1000*1000*1000}; $6~/^GB/{printf "%.f", $5*1000*1000*1000}; $6~/^MB/{printf "%u", $5*1000*1000}; $6~/^kB/{printf "%u", $5*1000}; $6~/^B/{print $5};'
}

borg_this_deduplicated(){
	grep -i "this archive" $1/status.txt | awk '$8~/^TB/{printf "%.f", $7*1000*1000*1000*1000}; $8~/^GB/{printf "%.f", $7*1000*1000*1000}; $8~/^MB/{printf "%u", $7*1000*1000}; $8~/^kB/{printf "%u", $7*1000}; $8~/^B/{print $7};'
}

borg_check(){
#	case $(grep -ci "no problems found" $1/status.txt) in 2*) echo 0;; *) echo 1;; esac
	if [[ ! -r "$1/status.txt" ]]
	then
		echo "${1}/status.txt missing or not readable"
		exit 1
	fi

	case $(grep -ci "no problems found" $1/status.txt 2> /dev/null) in
		2*)
			echo 0
			;;
		*)
			echo 1
			;;
	esac
}

case "$1" in
	"discover")
		borg_discover
		;;
	"start_time")
		borg_start_time $2
		;;
	"start_timestamp")
		borg_start_timestamp $2
		;;
	"end_time")
		borg_end_time $2
		;;
	"end_timestamp")
		borg_end_timestamp $2
		;;
	"all_original")
		borg_all_original $2
		;;
	"all_compressed")
		borg_all_compressed $2
		;;
	"all_deduplicated")
		borg_all_deduplicated $2
		;;
	"this_original")
		borg_this_original $2
		;;
	"this_compressed")
		borg_this_compressed $2
		;;
	"this_deduplicated")
		borg_this_deduplicated $2
		;;
	"check")
		borg_check $2
		;;
esac
exit 0
