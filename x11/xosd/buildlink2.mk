# $NetBSD: buildlink2.mk,v 1.5 2003/04/22 19:06:12 jmmv Exp $
#
# This Makefile fragment is included by packages that use xosd.
#
# This file was created automatically using createbuildlink 2.4.
#

.if !defined(XOSD_BUILDLINK2_MK)
XOSD_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xosd
BUILDLINK_DEPENDS.xosd?=		xosd>=2.2.1
BUILDLINK_PKGSRCDIR.xosd?=		../../x11/xosd

EVAL_PREFIX+=	BUILDLINK_PREFIX.xosd=xosd
BUILDLINK_PREFIX.xosd_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.xosd+=	include/xosd.h
BUILDLINK_FILES.xosd+=	lib/libxosd.*

BUILDLINK_TARGETS+=	xosd-buildlink

xosd-buildlink: _BUILDLINK_USE

.endif	# XOSD_BUILDLINK2_MK
