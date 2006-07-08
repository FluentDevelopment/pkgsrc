# $NetBSD: buildlink3.mk,v 1.31 2006/07/08 22:39:38 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
OPENSSL_BUILDLINK3_MK:=	${OPENSSL_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	openssl
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nopenssl}
BUILDLINK_PACKAGES+=	openssl
BUILDLINK_ORDER+=	openssl

.if !empty(OPENSSL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.openssl+=	openssl>=0.9.6m
BUILDLINK_ABI_DEPENDS.openssl+=	openssl>=0.9.7inb1
BUILDLINK_PKGSRCDIR.openssl?=	../../security/openssl

# Ensure that -lcrypt comes before -lcrypto when linking so that the
# system crypt() routine is used.
#
WRAPPER_REORDER_CMDS+=	reorder:l:crypt:crypto

SSLBASE=	${BUILDLINK_PREFIX.openssl}
BUILD_DEFS+=	SSLBASE
.endif	# OPENSSL_BUILDLINK3_MK

.if !defined(PKG_BUILD_OPTIONS.openssl)
PKG_BUILD_OPTIONS.openssl!=						\
	cd ${BUILDLINK_PKGSRCDIR.openssl} &&				\
	${MAKE} show-var ${MAKEFLAGS} VARNAME=PKG_OPTIONS
MAKEFLAGS+=	PKG_BUILD_OPTIONS.openssl=${PKG_BUILD_OPTIONS.openssl:Q}
.endif
MAKEVARS+=	PKG_BUILD_OPTIONS.openssl

.if !empty(PKG_BUILD_OPTIONS.openssl:Mrsaref)
.  include "../../security/rsaref/buildlink3.mk"
.endif

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
