#! /bin/sh
#
# $NetBSD: sasl_pwcheck.sh,v 1.5 2002/01/31 19:55:07 jlam Exp $
#
# The pwcheck daemon allows UNIX password authentication with Cyrus SASL.
#
# PROVIDE: sasl_pwcheck
# REQUIRE: DAEMON

if [ -e /etc/rc.subr ]
then
	. /etc/rc.subr
fi

rcd_dir=`@DIRNAME@ $0`

name="sasl_pwcheck"
rcvar="${name}"
command="@PREFIX@/sbin/pwcheck"
command_args="& sleep 2"
extra_commands="dbinit"

sasldb=@PKG_SYSCONFDIR@/sasldb.db

sasl_pwcheck_dbinit()
{
	(
	saslpasswd=@PREFIX@/sbin/saslpasswd
	umask 002
	if [ -e ${sasldb} ]
	then
		@ECHO@ "You already have an existing SASL password database"
		@ECHO@ "Skipping empty database generation"
	else
		@ECHO@ password | ${saslpasswd} -p user
		${saslpasswd} -d user
		@CHOWN@ @CYRUS_USER@ ${sasldb}
		@CHMOD@ 0600 ${sasldb}
	fi
	)
}

sasl_pwcheck_precmd()
{
	if [ ! -e ${sasldb} ]
	then
		$rcd_dir/sasl_pwcheck dbinit
	fi
}

dbinit_cmd=sasl_pwcheck_dbinit
start_precmd=sasl_pwcheck_precmd

if [ -e /etc/rc.subr ]
then
	load_rc_config $name
	run_rc_command "$1"
else
	@ECHO@ -n " ${name}"
	start_precmd
	${command} ${sasl_pwcheck_flags} ${command_args}
fi
