# $NetBSD: buildlink2.mk,v 1.4 2003/09/10 23:27:33 dmcmahill Exp $
#
# This Makefile fragment is included by packages that use libgdgeda.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(LIBGDGEDA_BUILDLINK2_MK)
LIBGDGEDA_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libgdgeda
BUILDLINK_DEPENDS.libgdgeda?=		libgdgeda>=2.0.15
BUILDLINK_PKGSRCDIR.libgdgeda?=		../../graphics/libgdgeda

EVAL_PREFIX+=	BUILDLINK_PREFIX.libgdgeda=libgdgeda
BUILDLINK_PREFIX.libgdgeda_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gd.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gd_io.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdfontg.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdfontl.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdfontmb.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdfonts.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdfontt.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdcache.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/gdhelpers.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/jisx0208.h
BUILDLINK_FILES.libgdgeda+=	include/gdgeda/wbmp.h
BUILDLINK_FILES.libgdgeda+=	lib/libgdgeda.*

.include "../../graphics/png/buildlink2.mk"

BUILDLINK_TARGETS+=	libgdgeda-buildlink

libgdgeda-buildlink: _BUILDLINK_USE

.endif	# LIBGDGEDA_BUILDLINK2_MK
