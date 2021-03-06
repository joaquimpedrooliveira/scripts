#!/bin/bash

set -e

# Script JBOSS 

#eth0
#ETH0=`LC_ALL= LANG= /sbin/ifconfig eth0 | grep 'inet addr:' | sed 's/.*inet addr://' | cut -d ' ' -f 1`

#Se JAVA_HOME não tiver configurado, usa a variável definida no script
if [ "x$JAVA_HOME" = "x" ]; then
    export JAVA_HOME=/opt/programas/jdk/jdk1.6.0_45
fi
#Se JAVA_OPTS não tiver configurado, usa a variável definida no script
if [ "x$JAVA_OPTS" = "x" ]; then
    export JAVA_OPTS="$JAVA_OPTS -server -d64 -Xss256k -XX:+UseParallelGC -XX:MaxPermSize=256m"
fi

ECHO=/bin/echo
TEST=/usr/bin/test
JBOSS_START_SCRIPT=/opt/programas/jboss-5.1.0.GA/bin/run.sh
JBOSS_STOP_SCRIPT=/opt/programas/jboss-5.1.0.GA/bin/shutdown.sh

$TEST -x $JBOSS_START_SCRIPT || exit 0
$TEST -x $JBOSS_STOP_SCRIPT || exit 0

start() {
      #Se nao foi passado nenhum parametro da instancia, usa a default
      if [ -z "$1" ] 
      then
        INSTANCIA=default
      else
        INSTANCIA=$1
      fi
      $ECHO -n "Iniciando o JBoss instância $INSTANCIA"
      # -Djboss.service.binding.set=ports-01
      $JBOSS_START_SCRIPT -c $INSTANCIA -b 0.0.0.0 -Dsun.rmi.dgc.server.gcInterval=3600000 -Dcom.sun.management.jmxremote -Dfile.encoding=ISO-8859-1 -Duser.language=pt -Duser.country=BR -Dorg.apache.catalina.STRICT_SERVLET_COMPLIANCE=false -Duser.timezone=Etc/GMT+3 -Djava.awt.headless=true > /dev/null 2> /dev/null &
      $ECHO "."
}

stop() {
     if [ -z "$1" ]
     then
       INSTANCIA=default
     else
       INSTANCIA=$1
     fi
     JBOSS_PID=`ps ax | grep jboss | grep "\-c $INSTANCIA" | awk '{print $1}'`
     if [ -z "$JBOSS_PID" ]
     then
        $ECHO "Não foi encontrado PID para JBoss da instância $INSTANCIA."
     else
     	$ECHO -n "Parando o JBoss instância $INSTANCIA"
     	kill -15 $JBOSS_PID
     	$ECHO "."
     fi
}

case "$1" in
      start)
            start $2
            ;;
      stop)
            stop $2
            ;;
      restart)
            stop $2
            sleep 30
            start $2
            ;;
      *)
            $ECHO "Uso: jboss {start|stop|restart} [instancia]. Se não for informada a instância, é utilizada a default."
            exit 1
esac

exit 0
