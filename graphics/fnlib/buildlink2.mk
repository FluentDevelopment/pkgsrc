# $NetBSD: buildlink2.mk,v 1.5 2003/07/13 13:52:00 wiz Exp $
#
# This Makefile fragment is included by packages that use fnlib.
#
# This file was created automatically using createbuildlink 2.6.
#

.if !defined(FNLIB_BUILDLINK2_MK)
FNLIB_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			fnlib
BUILDLINK_DEPENDS.fnlib?=		fnlib>=0.5nb5
BUILDLINK_PKGSRCDIR.fnlib?=		../../graphics/fnlib

EVAL_PREFIX+=	BUILDLINK_PREFIX.fnlib=fnlib
BUILDLINK_PREFIX.fnlib_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.fnlib+=	include/Fnlib*
BUILDLINK_FILES.fnlib+=	lib/libFnlib.*

.include "../../graphics/imlib/buildlink2.mk"

BUILDLINK_TARGETS+=	fnlib-buildlink

fnlib-buildlink: _BUILDLINK_USE

.endif	# FNLIB_BUILDLINK2_MK
