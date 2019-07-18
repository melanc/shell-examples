#!/bin/bash

TABLE_LIST=("fact_log_inf")

# 设置时间
TODAY_SEC=`date +%s`
DEL_DAY_SEC=`date -d "-3 day" +%s`
TODAY_DATE=`date -d @$TODAY_SEC "+%Y%m%d %H:%M:%S"`
DEL_DAY_DATE=`date -d @$DEL_DAY_SEC "+%Y%m%d %H:%M:%S"`
# DEL_DAY_MICRO=$((DEL_DAY*1000+`date "+%N"`/1000000))

HDFS_RM_BASE_PATH="/spock/openetl_parq/parquet-concat-rt"
HDFS_LS_BASE_PATH="$HDFS_RM_BASE_PATH/*/output"

echo "TODAY:$TODAY_DATE"
echo "DEL_DAY_DATE:$DEL_DAY_DATE"
echo "===== START CLEAN ====="

# 遍历目录，多进程处理
for table in ${TABLE_LIST[@]}; do {
  echo "==>process $$: $table"
  hdfs_path="$HDFS_LS_BASE_PATH/*$table*"
  # 只列出目录
  hdfs_list=`hadoop fs -ls -d $hdfs_path | awk '{print $8}'`
  for path in $hdfs_list; do {
    # 获取目录
    target_dir=`echo $path | awk -F "/" '{print $5}'`
    # 获取毫秒时间戳
    microtime=`echo $target_dir | awk -F "_" '{print $6}'`
    # 获取时间戳
    timestamp=${microtime:0:10}
    # 判断是否需要清理
    if [ $timestamp -lt $DEL_DAY_SEC ]; then
      clean_path=$HDFS_RM_BASE_PATH/$target_dir
      echo "DAY:"`date -d @$timestamp "+%Y-%m-%d %H"`
      echo "clean path:$clean_path"
      hadoop fs -rm -R "$clean_path"
    fi
  } done
} & done

# 等待所有进程退出
wait

echo "===== FINISH CLEAN ====="
