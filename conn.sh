#!/bin/sh
PORT=22
USER="user"
PASSWD="password"
case $1 in
"1")  IP=172.0.0.1;;
"2")  IP=172.0.0.2;;
*)
IP=$1;;
esac
expect -c "
spawn ssh -p $PORT $USER@$IP
expect {
	\"*yes/no*\" {send \"yes\r\"; exp_continue}
	\"*password*\" {send ${PASSWD}\r;}
	
}
interact
""
"