#!/bin/sh
#
# $NetBSD: maildirmake.sh,v 1.2 2002/01/01 08:00:45 jlam Exp $
#
# Wrapper to execute maildirmake from amongst any installed maildirmake
# executable.

maildirmake=
for file in @LOCALBASE@/bin/*.maildirmake
do
	if [ -x ${file} ]
	then
		maildirmake=${file}
	fi
done

if [ -z "${maildirmake}" ]
then
	@ECHO@ "$0: can't find a valid maildirmake executable"
	exit 1
fi

exec ${maildirmake} $*
