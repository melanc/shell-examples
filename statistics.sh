#!/bin/bash

# root dir
DATA_PATH="/data"
PACK="default"

# get date
STR=`ls $DATA_PATH/*/`
# 字符串转成数组
ARR=($STR)
TIME=${ARR[0]}
# 时间戳转日期
DATE=`date -d @"$TIME" +"%Y%m%d"`

OUT_FILE="/home/work/count_"$DATE".sta"

# process files
function func_count()
{
    for file in `ls $1`
    do
        if [ -d $1"/"$file ];then
            func_count $1"/"$file
        else
			# 去除扩展名
            filename=${file%.*}
			# 分割字符串
            OLD_IFS="$IFS"
            IFS="_"
            temp_arr=($filename)
            IFS="$OLD_IFS"

            package=$PACK
            bus_type=${temp_arr[0]}
            proto_type=${temp_arr[1]}
            index=${temp_arr[3]}
			# 获取文件字节数
            bytes=`stat --format=%s $1"/"$file`
			# 获取文件大小，单位M
            size=`awk 'BEGIN{printf "%.2f\n",'$bytes'/'1000000'}'`
			# 获取文件行数
            lines=`sed -n '$=' $1"/"$file`

			# 写入文件
            echo -e $index"\t"$package"\t"$filename"\t"$bus_type"\t"$proto_type"\t"$lines"\t"$size"\n" \
            >> $OUT_FILE

        fi
    done
}

# clean count file
function func_clean()
{
	# 清空文件
    echo -n "" > $OUT_FILE
}

# call func_count
func_clean
if [ "$1" = "" ];then
    func_count $DATA_PATH
else
    func_count $1
fi
