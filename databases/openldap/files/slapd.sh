#! /bin/sh
#
# $NetBSD: slapd.sh,v 1.3 2002/09/12 10:19:11 jlam Exp $
#
# OpenLDAP standalone LDAP daemon
#
# PROVIDE: slapd
# REQUIRE: DAEMON

if [ -f /etc/rc.subr ]
then
	. /etc/rc.subr
fi

name="slapd"
rcvar=${name}
command="@PREFIX@/libexec/${name}"
pidfile="/var/openldap/slapd.pid"
required_files="@PKG_SYSCONFDIR@/${name}.conf"
extra_commands="reload"

if [ -f /etc/rc.subr ]
then
	load_rc_config $name
	eval [ -z "\$${rcvar}" ] && eval ${rcvar}=NO
	run_rc_command "$1"
else
	@ECHO@ -n " ${name}"
	${command} ${slapd_flags} ${command_args}
fi
