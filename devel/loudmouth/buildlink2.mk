# $NetBSD: buildlink2.mk,v 1.4 2004/02/19 17:54:06 wiz Exp $
#
# This Makefile fragment is included by packages that use loudmouth.
#
# This file was created automatically using createbuildlink 2.6.
#

.if !defined(LOUDMOUTH_BUILDLINK2_MK)
LOUDMOUTH_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			loudmouth
BUILDLINK_DEPENDS.loudmouth?=		loudmouth>=0.10.1
BUILDLINK_PKGSRCDIR.loudmouth?=		../../devel/loudmouth

EVAL_PREFIX+=	BUILDLINK_PREFIX.loudmouth=loudmouth
BUILDLINK_PREFIX.loudmouth_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.loudmouth+=	include/loudmouth-1.0/loudmouth/*.h
BUILDLINK_FILES.loudmouth+=	lib/libloudmouth*
BUILDLINK_FILES.loudmouth+=	lib/pkgconfig/loudmouth-1.0.pc

.include "../../devel/glib2/buildlink2.mk"
.include "../../converters/libiconv/buildlink2.mk"
.if defined(LOUDMOUTH_USE_SSL) && !empty(LOUDMOUTH_USE_SSL:M[Yy][Ee][Ss])
BUILDLINK_DEPENDS.gnutls=	gnutls>=1.0.0
.include "../../security/gnutls/buildlink2.mk"
.endif

BUILDLINK_TARGETS+=	loudmouth-buildlink

loudmouth-buildlink: _BUILDLINK_USE

.endif	# LOUDMOUTH_BUILDLINK2_MK
