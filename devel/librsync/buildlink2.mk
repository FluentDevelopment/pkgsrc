# $NetBSD: buildlink2.mk,v 1.2 2003/07/13 13:51:21 wiz Exp $
#
# This Makefile fragment is included by packages that use librsync.
#
# This file was created automatically using createbuildlink 2.1.
#

.if !defined(LIBRSYNC_BUILDLINK2_MK)
LIBRSYNC_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			librsync
BUILDLINK_DEPENDS.librsync?=		librsync>=0.9.5.1nb1
BUILDLINK_PKGSRCDIR.librsync?=		../../devel/librsync

EVAL_PREFIX+=	BUILDLINK_PREFIX.librsync=librsync
BUILDLINK_PREFIX.librsync_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.librsync+=	include/rsync.h
BUILDLINK_FILES.librsync+=	lib/librsync.*

.include "../../archivers/bzip2/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../devel/popt/buildlink2.mk"
.include "../../devel/zlib/buildlink2.mk"

BUILDLINK_TARGETS+=	librsync-buildlink

librsync-buildlink: _BUILDLINK_USE

.endif	# LIBRSYNC_BUILDLINK2_MK
