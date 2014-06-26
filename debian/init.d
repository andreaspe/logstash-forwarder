#! /bin/sh
### BEGIN INIT INFO
# Provides:          logstash-forwarder
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: logstash-forwarder
# Description:       logstash-forwarder
#                    
### END INIT INFO

# Author: Jordan Sissel <jordan.sissel@dreamhost.com>

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="log shipper"
NAME=logstash-forwarder
DAEMON=/usr/bin/logstash-forwarder
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

[ -r /etc/default/$NAME ] && . /etc/default/$NAME
. /lib/init/vars.sh
. /lib/lsb/init-functions

COMMAND="cd /var/run; exec $DAEMON $DAEMON_ARGS"

do_start() {
  # Skip if it's already running
  start-stop-daemon --start --quiet --pidfile $PIDFILE --exec /bin/sh --test > /dev/null || return 1

  cd /var/run
  # Actually start it now.
  start-stop-daemon --start --quiet --make-pidfile --background \
    --pidfile $PIDFILE --exec /bin/sh -- -c "$COMMAND" || return 2
}

do_stop()
{
  start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE
  RETVAL="$?"
  [ "$RETVAL" = 2 ] && return 2
  start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
  [ "$?" = 2 ] && return 2
  rm -f $PIDFILE
  return "$RETVAL"
}


case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    do_start
    ;;
  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    ;;
  status)
    status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
    ;;
  restart|force-reload)
    log_daemon_msg "Restarting $DESC" "$NAME"
    do_stop
    case "$?" in
      0|1)
        do_start
      ;;
      *)
        # Failed to stop
        log_end_msg 1
      ;;
    esac
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
    exit 3
    ;;
esac
