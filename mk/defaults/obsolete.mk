# $NetBSD: obsolete.mk,v 1.18 2005/12/01 19:07:06 wiz Exp $
#
# This file holds make(1) logic to allow obsolete or deprecated variables
# still to be used.  These may eventually disappear over time as the contents
# are, by definition, obsolete and deprecated.

.if defined(PRIV_CONF_DIR)
PKG_SYSCONFDIR.priv?=	${PRIV_CONF_DIR}
.endif

###
### Set PKG_LEGACY_OPTIONS based on to-be-deprecated global variables.
###

.if defined(KERBEROS)
.  if ${KERBEROS} == "4" && !empty(PKG_SUPPORTED_OPTIONS:Mkerberos4)
PKG_LEGACY_OPTIONS+=	kerberos4
PKG_OPTIONS_DEPRECATED_WARNINGS+="Deprecated variable KERBEROS used, use PKG_DEFAULT_OPTIONS+=kerberos4 instead."
.  elif !empty(PKG_SUPPORTED_OPTIONS:Mkerberos)
PKG_LEGACY_OPTIONS+=	kerberos
PKG_OPTIONS_DEPRECATED_WARNINGS+="Deprecated variable KERBEROS used, use PKG_DEFAULT_OPTIONS+=kerberos instead."
.  endif
.endif
.if defined(USE_SOCKS)
.  if ${USE_SOCKS} == "4" && !empty(PKG_SUPPORTED_OPTIONS:Msocks4)
PKG_LEGACY_OPTIONS+=	socks4
PKG_OPTIONS_DEPRECATED_WARNINGS+="Deprecated variable SOCKS used, use PKG_DEFAULT_OPTIONS+=socks4 instead."
.  elif ${USE_SOCKS} == "5" && !empty(PKG_SUPPORTED_OPTIONS:Msocks5)
PKG_LEGACY_OPTIONS+=	socks5
PKG_OPTIONS_DEPRECATED_WARNINGS+="Deprecated variable SOCKS used, use PKG_DEFAULT_OPTIONS+=socks5 instead."
.  endif
.endif

PKG_OPTIONS_LEGACY_OPTS+=	postgresql:pgsql
PKG_OPTIONS_LEGACY_OPTS+=	postgresql73:pgsql
PKG_OPTIONS_LEGACY_OPTS+=	postgresql74:pgsql

PKG_OPTIONS_LEGACY_VARS+=	USE_INET6:inet6
PKG_OPTIONS_LEGACY_VARS+=	USE_INN:inn
PKG_OPTIONS_LEGACY_VARS+=	USE_OPENLDAP:ldap
PKG_OPTIONS_LEGACY_VARS+=	USE_OSS:oss
PKG_OPTIONS_LEGACY_VARS+=	USE_RSAREF2:rsaref
PKG_OPTIONS_LEGACY_VARS+=	USE_XFACE:xface

# remove after 2005Q4
PKG_OPTIONS_LEGACY_VARS+=	USE_CANNA:canna
PKG_OPTIONS_LEGACY_VARS+=	USE_CUPS:cups
PKG_OPTIONS_LEGACY_VARS+=	USE_I586:i586
PKG_OPTIONS_LEGACY_VARS+=	USE_SASL:sasl
PKG_OPTIONS_LEGACY_VARS+=	USE_SASL2:sasl
PKG_OPTIONS_LEGACY_VARS+=	USE_SJ3:sj3
PKG_OPTIONS_LEGACY_VARS+=	USE_WNN4:wnn4
