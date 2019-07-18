#!/bin/sh

# chmod a+x deploy.sh
date=$(date +%Y_%m_%d)
time=$(date +%Y_%m_%d_%H%M%S)
##################################### START CONFIG #####################################
MV_CFG=@@MV_CFG

PHP_OWNER=@@PHP_OWNER
PHP_GROUP=@@PHP_GROUP
PHP_PERM=@@PHP_PERM

amc_db=@@DB_NAME
adwords_db=@@ADWORDS_DB_NAME

# MYSQL DB CONFIG
MYSQL_HOST=@@DB_HOST
MYSQL_PORT=@@DB_PORT
MYSQL_USER=@@DB_USER
MYSQL_PASS=@@DB_PASS

MYSQL_ROOT_USER=@@DB_ROOT_USER
MYSQL_ROOT_PASS=@@DB_ROOT_PASS
MYSQL_ACCESS_HOST=@@DB_ACCESS

webroot=@@WEB_ROOT
amc_dir=@@AMC_PATH
amc_path=${webroot}/${amc_dir}

amc_bak=${amc_dir}_${date}.tar.gz
sql_bak=${amc_db}_${date}.sql
bak_path=@@BACK_PATH/$date

amc_bak_ever=${amc_dir}_${time}.tar.gz
sql_bak_ever=${amc_db}_${time}.sql

script_path=`dirname $0`
root_path=$(cd ${script_path}/..; pwd)

config=$root_path/Common/config.php
config_ex=$root_path/Common/config.example.php

boot_inc=$root_path/Adwords/ToAdwords/bootstrap.inc.php
boot_inc_ex=$root_path/Adwords/ToAdwords/bootstrap.inc.example.php

conf=$root_path/Adwords/Code/conf.php
conf_ex=$root_path/Adwords/Code/conf.example.php

amc_init_sql=$root_path/Script/sql/init/dsp_amc_init.sql
adwords_init_sql=$root_path/Script/sql/init/dsp_adwords_init.sql
amc_update_sql=$root_path/Script/sql/update/amc_update_${date}.sql
##################################### END CONFIG #####################################
echo ' ================= Deploy Start ================='
read -p ' * Please input a param [upgrade|rollback|initialise]:' cmd
if [ "$cmd" != 'upgrade' -a "$cmd" != 'rollback' -a "$cmd" != 'initialise' ]; then
	echo ' * Invalid params, exit!'
	exit
fi

# Upgrade code and db
if [ "$cmd" = 'upgrade' ]; then
	while true; do
		read -p " * Confirm upgrade [y/n]:" yn
		case "$yn" in
			y|yes|Yes|YES) echo ' * ******* Upgrade start ********'; break;;
			[nN]*) echo ' * Exit on user cmd'; exit;;
			*) echo ' * Please answer y or n.';;
		esac
	done
	
	cd $webroot

	# check backup path is exists or not
	if [ ! -x $bak_path ]; then
		mkdir -p $bak_path
	fi
	
	#backup old code
	echo ' * code backup'
	tar -zcf $amc_bak $amc_dir

	#backup old db
	echo ' * mysql backup'
	mysqldump -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT --opt $amc_db > $sql_bak

	# move backup file to backup path
	echo ' * move backup file'
	if [ -f $amc_bak ]; then
		cp -rf $amc_bak $bak_path/$amc_bak_ever
		mv -f $amc_bak $bak_path
	else
		echo ' * code backup failed, exit!'
		exit
	fi
	
	if [ -f $sql_bak ]; then
		cp -rf $sql_bak $bak_path/$sql_bak_ever
		mv -f $sql_bak $bak_path
	else
		echo ' * data backup failed, exit!'
		exit
	fi
	
	# upgrade db
	if [ -f $amc_update_sql ]; then
		echo " * upgrade sql"
		mysql -u$MYSQL_USER -P$MYSQL_PORT -p$MYSQL_PASS $amc_db < $amc_update_sql
	fi
	
	# upgrade code
	echo ' * upgrade code'
	\cp -rf $root_path/* $amc_path
	
	# mv config 
	if [ $MV_CFG = 1 ]; then
		\cp -rf $config_ex $config
		\cp -rf $boot_inc_ex $boot_inc
		\cp -rf $conf_ex $conf
	fi
	
	echo ' * ******* Upgrade done~ ********'
	
# Rollback code and db
elif [ "$cmd" = 'rollback' ]; then
	while true; do
		read -p " * Confirm rollback [y/n]:" yn
		case "$yn" in
			y|yes|Yes|YES) echo ' * ******* Rollback start ********'; break;;
			[nN]*) echo ' * Exit on user cmd'; exit;;
			*) echo ' * Please answer y or n.';;
		esac
	done
	
	cd $webroot

	# rollback code
	echo ' * rollback code'
	\cp $bak_path/$amc_bak $webroot
	tar -zxf $amc_bak
	rm -rf $amc_bak

	# rollback db
	echo ' * rollback sql'
	mysql -u$MYSQL_USER -P$MYSQL_PORT -p$MYSQL_PASS -h$MYSQL_HOST $amc_db < "$bak_path/$sql_bak"
	
	echo ' * ******* Rollback done~ ********'
# Initialise code and db
elif [ "$cmd"='initialise' ]; then
	while true; do
		read -p " * Confirm initialise [y/n]:" yn
		case "$yn" in
			y|yes|Yes|YES) echo ' * ******* Initialise start ********'; break;;
			[nN]*) echo ' * Exit on user cmd'; exit;;
			*) echo ' * Please answer y or n.';;
		esac
	done
	
	cd $webroot

	# check amc path is exists or not
	if [ ! -x $amc_path ]; then
		mkdir -p $amc_path
	fi
	
	# create new db
	echo ' * mysql create db'
	mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e"CREATE DATABASE $amc_db DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
	mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e"CREATE DATABASE $adwords_db DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
	
	# determine db user exists or not
	query_user=`mysql -uroot -p123456 mysql -e"SELECT * FROM user WHERE User='$MYSQL_USER' and Host='$MYSQL_ACCESS_HOST'"`

	# grant all privileges
	if [ -z "$query_user" ]; then
		echo ' * mysql grant privileges with passwd'
		mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e"grant ALL privileges on ${amc_db}.* to '$MYSQL_USER'@'$MYSQL_ACCESS_HOST' identified by '$MYSQL_PASS';"
		mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e"grant ALL privileges on ${adwords_db}.* to '$MYSQL_USER'@'$MYSQL_ACCESS_HOST';"
	else
		echo ' * mysql grant privileges'
		mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e"grant ALL privileges on ${amc_db}.* to '$MYSQL_USER'@'$MYSQL_ACCESS_HOST';"
		mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e"grant ALL privileges on ${adwords_db}.* to '$MYSQL_USER'@'$MYSQL_ACCESS_HOST';"

	fi

	# init db
	echo ' * initialise sql'
	if [ -f $amc_init_sql ]; then
		mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT $amc_db < $amc_init_sql
	fi
	if [ -f $adwords_init_sql ]; then
		mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT $adwords_db < $adwords_init_sql
	fi
	
	# upgrade code
	echo ' * initialise code'
	\cp -rf $root_path/* $amc_path
	# mv config
	\cp -Rf $config_ex $config
	\cp -Rf $boot_inc_ex $boot_inc
	\cp -Rf $conf_ex $conf

	echo ' * ******* Initialise done~ ********'
fi

# modify role and permission
if [ "$cmd" = 'upgrade' -a "$cmd" = 'rollback' -a "$cmd" = 'initialise' ]; then
	echo ' * modify role and perm'
	chown -R $PHP_OWNER:$PHP_GROUP $amc_path
	chmod -R $PHP_PERM $amc_path
fi

echo ' ================= Deploy Finish~ ================='
