# $NetBSD: buildlink2.mk,v 1.2 2004/03/26 02:27:43 wiz Exp $
#
# This Makefile fragment is included by packages that use cyrus-imapd.
#
# This file was created automatically using createbuildlink 2.4.
#

.if !defined(CYRUS_IMAPD_BUILDLINK2_MK)
CYRUS_IMAPD_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			cyrus-imapd
BUILDLINK_DEPENDS.cyrus-imapd?=		cyrus-imapd>=2.0.17
BUILDLINK_RECOMMENDED.cyrus-imapd?=		cyrus-imapd>=2.0.17nb3
BUILDLINK_PKGSRCDIR.cyrus-imapd?=		../../mail/cyrus-imapd

EVAL_PREFIX+=	BUILDLINK_PREFIX.cyrus-imapd=cyrus-imapd
BUILDLINK_PREFIX.cyrus-imapd_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.cyrus-imapd+=	include/cyrus/*.h
BUILDLINK_FILES.cyrus-imapd+=	lib/libacap.*
BUILDLINK_FILES.cyrus-imapd+=	lib/libcyrus.*

.include "../../databases/db3/buildlink2.mk"
.include "../../security/cyrus-sasl/buildlink2.mk"
.include "../../security/openssl/buildlink2.mk"
.include "../../security/tcp_wrappers/buildlink2.mk"

BUILDLINK_TARGETS+=	cyrus-imapd-buildlink

cyrus-imapd-buildlink: _BUILDLINK_USE

.endif	# CYRUS_IMAPD_BUILDLINK2_MK
