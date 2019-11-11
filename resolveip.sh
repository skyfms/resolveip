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
# IPv6 regex from https://stackoverflow.com/questions/53497/regular-expression-that-matches-valid-ipv6-addresses
IPV6_MASK="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"

function notfoundmsg()
{
	(>&2 echo "$(basename $0): Unable to find hostid for '$1': host not found")
}

if grep -qsE "$IPV4_MASK" <<< "$host_or_ip" || grep -qsE "$IPV6_MASK" <<< "$host_or_ip"; then
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
