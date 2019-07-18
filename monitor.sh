#!/bin/bash
 
# 脚本作用：监控守护进程是否运行
# 执行方式：crontab 
# */1 * * * * /bin/bash /var/www/html/../monitorAmc.sh >> /var/log/../monitorAmc.log &

php='/usr/local/php/bin/php'

subject='[monitor] amc monitor'
fromname='monitor'
frommail='monitor@izptec.com'
toname='wanghedong'
tomail='wanghedong@izptec.com'

function send_mail() {
    msg="\n time : `date '+%Y-%m-%d %H:%M:%S'`
         \n host : `hostname`
         \n info : $1"
    cmd="To: ${toname} <${tomail}> 
         \nFrom: ${fromname} <${frommail}> 
         \nSubject: ${subject}
         \n\n ${msg}"
    echo -e ${cmd} | /usr/sbin/sendmail -t
}

#输出监控日期时间
date '+[%Y-%m-%d %H:%M:%S]'

#脚本所在目录
script_path=`dirname $0`

cd "$script_path"

#查看[httpsqs]进程是否存在
httpsqs_info=`ps aux | grep httpsqs | grep -v grep`
httpsqs_msg='httpsqs died! restart now!'

#不存在则启动并发送报警
if [ -z "$httpsqs_info" ]; then
    #记录日志
    echo "$httpsqs_msg"
    #重新启动
    httpsqs -d -p 1218 -a 123456 -x /data0/queue
    #邮件通知
    send_mail "$httpsqs_msg"
fi

#查看 common.php和retry.php是否存在
adwords_path="${script_path}/../Adwords/ToAdwords/Script"
common_info=`ps aux | grep dsp_common.php | grep -v grep`
common_msg='dsp_common.php died! restart new!'

if [ "$common_info" = "" ]; then
    echo "$common_msg"
    cd "$adwords_path"
    nohup $php -q dsp_common.php >> dsp_common.log &
    send_mail "$common_msg"
fi


retry_info=`ps aux | grep dsp_retry.php | grep -v grep`
retry_msg='dsp_retry.php died! restart now!'

if [ "$retry_info" = "" ]; then
    echo "$retry_msg"
    cd "$adwords_path"
    nohup $php -q dsp_retry.php >> dsp_retry.log &
    send_mail "$retry_msg"
fi

#查看报表下载main.php
report_path="${script_path}/../Adwords/Code"
report_info=`ps aux | grep dsp_main.php | grep -v grep`
report_msg='dsp_main.php died! restart now!'

if [ "$report_info" = "" ]; then
    echo "$report_msg"
    cd "$report_path"
    nohup $php dsp_main.php >> dsp_main.log &
    send_mail "$report_msg"
fi
