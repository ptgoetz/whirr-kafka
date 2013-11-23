#! /bin/sh
# /etc/init.d/kafka: start the kafka daemon.

# chkconfig: 345 80 20
# description: kafka

KAFKA_HOME=/usr/share/kafka
USER=kafka

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin

prog=kafka
DESC="kafka daemon"

RETVAL=0

# detect the distribution:
if [ -f /etc/redhat-release -o -f /etc/fedora-release ] ; then
  DISTRIBUTION="redhat"
elif [ -f /etc/SuSE-release ] ; then
  DISTRIBUTION="suse"
elif [ -f /etc/debian_version ] ; then
  DISTRIBUTION="debian"
else
  DISTRIBUTION="debian"
fi

# Source function library.
[ "$DISTRIBUTION" = "redhat" ] && . /etc/init.d/functions
[ "$DISTRIBUTION" = "suse" ] && . /etc/rc.status

if [ "$DISTRIBUTION" = "suse" ] ; then
  echo_success() {
    rc_status -v
  }
  echo_failure() {
    rc_status -v
  }
  success() {
    echo_success
  }
  failure() {
    echo_success
  }
elif [ "$DISTRIBUTION" = "debian" ] ; then
  echo_success() {
    echo ok
  }
  echo_failure() {
    echo failed
  }
  success() {
    echo_success
  }
  failure() {
    echo_success
  }
fi

start() {
  echo -n "Starting $prog: "
  cd $KAFKA_HOME
  nohup su $USER -c "./bin/kafka-server-start.sh /etc/kafka/server.properties </dev/null 2>&1 | cronolog ./log/kafka/kafka.%Y%m%d.log 2>&1" </dev/null >/dev/null 2>&1 &
  RETVAL=$?
  [ $RETVAL -eq 0 ] && echo_success
  [ $RETVAL -ne 0 ] && echo_failure
  return $RETVAL
}

stop() {
  echo -n "Stopping $prog: "
  pkill -f kafka.Kafka
  RETVAL=$?
  [ $RETVAL -eq 0 ] && echo_success
  [ $RETVAL -ne 0 ] && echo_failure
  return $RETVAL
}

reload() {
  stop
  start
}

restart() {
  stop
  start
}

case "$1" in
start)
  start
  ;;

stop)
  stop
  ;;

reload)
  reload
  ;;

restart)
  restart
  ;;

*)
  echo "Usage: $0 {start|stop|reload|restart}"
  exit 1
esac

exit $?
