#!/bin/bash

#date_old=`date -d '-3day' +"%Y-%m-%d"`
date_old=`date -d '-3day' +"%s"`

path=$(cd `dirname $0`; pwd)
data_path=${path}/web/data
cd ${data_path}
dir_list=`ls`
if [ "${dir_list}" != "" ]; then
	for i in ${dir_list}; do
		echo $i
		if [ $i -lt $date_old ]; then
			echo "delete $i"
			rm -rf $i
		fi
	done
fi