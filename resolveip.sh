#!/usr/bin/env bash

if [ "$1" == "" ] || [ "$1" == "-?" ]; then
	echo "Get hostname based on IP address or IP address based on hostname."
	echo "Usage: $(basename $0) [options] host_or_ip"
	echo "Options:"
	echo "	-?		Display this help and exit."
	echo "	-s		Be more silent."
	exit
fi

silent=0
if [ "$1" == "-s" ]; then
	silent=1
	shift
fi

host_or_ip="$1"

IPV4_MASK="[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
# TODO: IPv6 support

function notfoundmsg()
{
	(>&2 echo "$(basename $0): Unable to find hostid for '$1': host not found")
}

if grep -qsE "$IPV4_MASK" <<< "$host_or_ip"; then
	host="$(getent hosts $host_or_ip | sed "s/\s\+/\t/g" | cut -f 2 | head -n 1)"
	if [ "$host" == "" ]; then
		notfoundmsg $host_or_ip
		exit 1
	fi
	if [ "$silent" == "1" ]; then
		echo "$host"
	else
		echo "Host name of $host_or_ip is $host"
	fi
else
	ip="$(getent ahosts $host_or_ip | sed "s/\s\+/\t/g" | cut -f 1 | head -n 1)"
	if [ "$ip" == "" ]; then
		notfoundmsg $host_or_ip
		exit 1
	fi
	if [ "$silent" == "1" ]; then
		echo "$ip"
	else
		echo "IP address of $host_or_ip is $ip"
	fi
fi
