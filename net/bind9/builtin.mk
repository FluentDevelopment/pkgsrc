# $NetBSD: builtin.mk,v 1.2 2004/07/18 11:22:13 tron Exp $

.if !defined(IS_BUILTIN.bind)
IS_BUILTIN.bind=        no
.  if exists(/usr/sbin/named)
_BIND_VERSION!=/usr/sbin/named -v | ${HEAD} -1 | ${CUT} -d ' ' -f 2
.  endif
.  if defined(_BIND_VERSION) && !empty(_BIND_VERSION)
IS_BUILTIN.bind=        yes
BUILTIN_PKG.bind=       bind-${_BIND_VERSION}
BUILDLINK_VARS+=        BUILTIN_PKG.bind
.  endif
.endif  # IS_BUILTIN.bind
BUILDLINK_VARS+=        IS_BUILTIN.bind

USE_BUILTIN.bind?=      ${IS_BUILTIN.bind}
