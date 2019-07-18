#!/bin/bash
##### check php syntax #####

function check_syntax(){
    cd "$1"
    for file in *
        do
            if [ -f $file ]; then
                ext=${file#*.}
                if [ $ext = "php" ]; then
                    ${php} -l $file | grep -v "$2"
                fi
            fi
            if [ -d $file ]; then
                (check_syntax "$PWD/$file" "$info")
            fi
        done
}

path=`dirname $0`"/.."
info="No syntax errors detected"
php='/usr/local/php/bin/php'

echo "============================ check syntax start ============================"
check_syntax "$path" "$info"
echo "============================ check syntax end   ============================"
