#!@RCD_SCRIPTS_SHELL@
#
# $NetBSD$
#
# PROVIDE: greyd
# REQUIRE: DAEMON
#

. /etc/rc.subr

name="greyd"
rcvar=$name
command="@PREFIX@/libexec/greyd"
required_files="@GREYD_CONF@"

greyd_postcmd()
{
	if [ -x @PREFIX@/libexec/greyd-setup ]; then
		@PREFIX@/libexec/greyd-setup
	fi
}

load_rc_config $name
run_rc_command "$1"
