# $NetBSD: buildlink2.mk,v 1.3 2003/05/02 11:54:36 wiz Exp $
#
# This Makefile fragment is included by packages that use libgtop.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(LIBGTOP_BUILDLINK2_MK)
LIBGTOP_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libgtop
BUILDLINK_DEPENDS.libgtop?=		libgtop>=1.0.13nb2
BUILDLINK_PKGSRCDIR.libgtop?=		../../devel/libgtop

EVAL_PREFIX+=	BUILDLINK_PREFIX.libgtop=libgtop
BUILDLINK_PREFIX.libgtop_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.libgtop+=	include/libgtop-1.0/*.h
BUILDLINK_FILES.libgtop+=	include/libgtop-1.0/glibtop/*.h
BUILDLINK_FILES.libgtop+=	lib/libgtop-features.def
BUILDLINK_FILES.libgtop+=	lib/libgtop.*
BUILDLINK_FILES.libgtop+=	lib/libgtopConf.sh
BUILDLINK_FILES.libgtop+=	lib/libgtop_common.*
BUILDLINK_FILES.libgtop+=	lib/libgtop_names.*
BUILDLINK_FILES.libgtop+=	lib/libgtop_suid_common.*
BUILDLINK_FILES.libgtop+=	lib/libgtop_sysdeps.*
BUILDLINK_FILES.libgtop+=	lib/libgtop_sysdeps_suid.*

.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"

BUILDLINK_TARGETS+=	libgtop-buildlink

libgtop-buildlink: _BUILDLINK_USE

.endif	# LIBGTOP_BUILDLINK2_MK
