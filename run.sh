#!/bin/bash

#chmod +x run.sh
php=/usr/local/php/bin/php

path=$(cd `dirname $0`; pwd)

# function
function Start()
{
	echo "start sync and rtc..."
	nohup ${php} yii sync/index > /dev/null 2>&1 &
	nohup ${php} yii sync/rtc > /dev/null 2>&1 &
	echo "done."
}

function Stop()
{
	echo "stop sync and rtc..."
	process=`ps -ef|grep "sync/index\|sync/rtc" | grep -v grep`
	if [ "${process}" != "" ]; then
		for i in "${process}"; do
			pid=`echo "$i" | awk -F ' ' '{print $2}'`
			kill $pid
		done
	fi
	echo "done."
}

function Status()
{
	echo "show status of sync and rtc..."
	process=`ps -ef|grep "sync/index\|sync/rtc" | grep -v grep`
	if [ "${process}" != "" ]; then
		for i in "${process}"; do
			echo "$i\n"
		done
	fi
}

# call function
if [ "$1" = "" -o "$1" = "start" ]; then
	Start
elif [ "$1" = "stop" ]; then
	Stop
elif [ "$1" = "restart" ]; then
	Stop
	Start
elif [ "$1" = "status" ]; then
	Status
else
	echo "nothing to do..."
fi
