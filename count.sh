#!/bin/bash
files_cnt=0
lines_cnt=0
function fun_count()
{
    for file in ` ls $1 `
    do
        if [ -d $1"/"$file ];then
            fun_count $1"/"$file
        else
            declare -i fileLines
            fileLines=`sed -n '$=' $1"/"$file`
            let lines_cnt=$lines_cnt+$fileLines
            let files_cnt=$files_cnt+1
        fi
    done
}
if [ $# -gt 0 ];then
    for m_dir in $@
    do
        fun_count $m_dir
    done
else
    fun_count "."
fi
echo "files = $files_cnt"
echo "lines = $lines_cnt"