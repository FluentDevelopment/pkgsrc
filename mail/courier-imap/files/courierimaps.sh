#!@RCD_SCRIPTS_SHELL@
#
# $NetBSD: courierimaps.sh,v 1.8 2004/02/24 01:18:52 jlam Exp $
#
# Courier IMAP/SSL services daemon
#
# PROVIDE: courierimaps
# REQUIRE: authdaemond

if [ -f /etc/rc.subr ]; then
	. /etc/rc.subr
fi

name="courierimaps"
rcvar=${name}
command="@PREFIX@/libexec/courier/couriertcpd"
ctl_command="@PREFIX@/libexec/courier/imapd-ssl.rc"
pidfile="/var/run/imapd-ssl.pid"
required_files="@PKG_SYSCONFDIR@/imapd @PKG_SYSCONFDIR@/imapd-ssl"
required_files="${required_files} @SSLCERTS@/imapd.pem"

start_cmd="courier_doit start"
stop_cmd="courier_doit stop"

courier_doit()
{
	action=$1
	case ${action} in
	start)
		for f in $required_files; do
			if [ ! -r "$f" ]; then
				@ECHO@ "$0: WARNING: $f is not readable"
				if [ -z $rc_force ]; then
					return 1
				fi
			fi
		done
		@ECHO@ "Starting ${name}."
		;;
	stop)
		@ECHO@ "Stopping ${name}."
		;;
	esac

	${ctl_command} ${action}
}

if [ -f /etc/rc.subr ]; then
	load_rc_config $name
	run_rc_command "$1"
else
	@ECHO@ -n " ${name}"
	${start_cmd}
fi
