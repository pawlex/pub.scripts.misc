#!/bin/sh

# THIS WILL CONNECT A JAVAWS SESSION TO LANTRONIX IPKVM WITHOUT HAVING TO LOG-IN TO THE WEB INTERFACE.
# You will need to modify "" to allow the execution of unsigned .jars
## See: https://unix.stackexchange.com/questions/143805/running-unsigned-javaws-code/401275#401275
#
$USERNAME="CHANGEME"
$PASSWORD="CHANGEME"
$IPADDRESS=127.0.0.1
#
STORECOOKIE="--cookie-jar cookie.curl"
LOADCOOKIE="-b cookie.curl"
#
AUTH=`curl -s ${STORECOOKIE} --data "nickname=''&login=$USERNAME&password=$PASSWORD&action_login=Login" http://$IPADDRESS/auth.asp`
RETVAL=`curl -s ${LOADCOOKIE} http://$IPADDRESS/home.asp`
ID=`echo ${RETVAL} | awk -F'=' '{ print $49}' | awk -F"'" '{ print $1 }'`
curl -s ${LOADCOOKIE} -o spider.jnlp http://$IPADDRESS/spider.jnlp?r=${ID}
javaws ./spider.jnlp
