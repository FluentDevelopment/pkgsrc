# $NetBSD: buildlink2.mk,v 1.2 2004/03/08 19:52:51 minskim Exp $
#
# This Makefile fragment is included by packages that use libstroke.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(LIBSTROKE_BUILDLINK2_MK)
LIBSTROKE_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libstroke
BUILDLINK_DEPENDS.libstroke?=		libstroke>=0.3nb1
BUILDLINK_PKGSRCDIR.libstroke?=		../../devel/libstroke

EVAL_PREFIX+=	BUILDLINK_PREFIX.libstroke=libstroke
BUILDLINK_PREFIX.libstroke_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libstroke+=	lib/libstroke.*
BUILDLINK_FILES.libstroke+=	lib/libstroke_tcl.*

.include "../../lang/tcl83/buildlink2.mk"

BUILDLINK_TARGETS+=	libstroke-buildlink

libstroke-buildlink: _BUILDLINK_USE

.endif	# LIBSTROKE_BUILDLINK2_MK
