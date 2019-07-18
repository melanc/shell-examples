#!/bin/bash

eval "lh $1 >/dev/null || lh $1 || exit 1"
for x in `eval "lh $1"` 
do
        echo -e -n "\033[40;32m ------------------------"
        echo -e -n "\033[40;32m $x"
        echo -e "\033[40;32m ------------------------"
        echo -e -n "\033[40;37m"
        #eval "ssh $x '$2'" || exit 1 
        eval "ssh $x '$2'"
        #ssh $x "$2"
done