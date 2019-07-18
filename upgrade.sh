#!/bin/sh

AMC_PATH='/home/root/workspace/amc/'
BACKUP_FILENAME='/root/backup.tar.gz'
MYSQL_BACKUPFILE='/root/20140113_mmc.sql'
MYSQL_USER='root'
MYSQL_PORT=13306
MYSQL_PASS='#####'
MYSQL_DB='mmc'

if [ ! -n $1 ]
    then
    echo "PARAMRS MISSING"
    exit
fi
if [ $1'i' = 'upgradei' ]
    then

    echo "[upgrading...]"

    echo "[code backup]"

    tar -zcvPf $BACKUP_FILENAME $AMC_PATH 

    echo "[mysql backup]"

    mysqldump -u$MYSQL_USER -P$MYSQL_PORT -p$MYSQL_PASS $MYSQL_DB > $MYSQL_BACKUPFILE
    
    echo "[upgradeing sql]"
    
    mysql -u$MYSQL_USER -P$MYSQL_PORT -p$MYSQL_PASS $MYSQL_DB < 'Update.sql'
    
    echo "[upgradeing code]"
    
    cp -Rf './MapModel/Class/' $AMC_PATH'MapModel/'
    
    echo "[down!~]"
elif [ $1'i' = 'rollbacki' ]
    then
    echo "[rollback...]"

    echo "[rollbacking code]"

    tar -xvPf $BACKUP_FILENAME

    echo "[rollbacking sql]"

    mysql -u$MYSQL_USER -P$MYSQL_PORT -p$MYSQL_PASS < $MYSQL_BACKUPFILE

else
    echo "[Unkown Params,upgrade\rollback]"
fi
