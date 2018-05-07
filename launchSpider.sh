#!/bin/sh

# THIS WILL CONNECT A JAVAWS SESSION TO LANTRONIX IPKVM WITHOUT HAVING TO LOG-IN TO THE WEB INTERFACE.
# You will need to modify "" to allow the execution of unsigned .jars
## See: https://unix.stackexchange.com/questions/143805/running-unsigned-javaws-code/401275#401275



$USERNAME="CHANGEME"
$PASSWORD="CHANGEME"
$IPADDRESS=127.0.0.1

STORECOOKIE="--cookie-jar cookie.curl"
LOADCOOKIE="-b cookie.curl"
JAVAOPTS="-Djava.security.policy=/home/pawl/.config/icedtea-web/security/javaws.policy"

AUTH=`curl -s ${STORECOOKIE} --data "nickname=''&login=$USERNAME&password=$PASSWORD&action_login=Login" http://$IPADDRESS/auth.asp`
RETVAL=`curl -s ${LOADCOOKIE} http://$IPADDRESS/home.asp`
#echo ${RETVAL} | sed 's/spider.jnlp\?r=(.*)/g'
#echo ${RETVAL} | awk -F'r\=' '{ print $2 }'
#echo ${RETVAL} | sed '/\?r\=/,/title\=/p'
ID=`echo ${RETVAL} | awk -F'=' '{ print $49}' | awk -F"'" '{ print $1 }'`
curl -s ${LOADCOOKIE} -o spider.jnlp http://$IPADDRESS/spider.jnlp?r=${ID}
#javaws -Xignoreheaders -nosecurity ./spider.jnlp
#strace javaws ./spider.jnlp 1>java.log 2>>java.log
#strace javaws ./spider.jnlp $JAVAOPTS 1>java.log 2>>java.log
#javaws ./spider.jnlp $JAVAOPTS
javaws ./spider.jnlp
