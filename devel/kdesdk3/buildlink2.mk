# $NetBSD: buildlink2.mk,v 1.1 2003/01/09 11:21:41 uebayasi Exp $
#
# This Makefile fragment is included by packages that use kdesdk.
#
# This file was created automatically using createbuildlink 2.4.
#

.if !defined(KDESDK_BUILDLINK2_MK)
KDESDK_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			kdesdk
BUILDLINK_DEPENDS.kdesdk?=		kdesdk>=3.0.5.1
BUILDLINK_PKGSRCDIR.kdesdk?=		../../devel/kdesdk3

EVAL_PREFIX+=	BUILDLINK_PREFIX.kdesdk=kdesdk
BUILDLINK_PREFIX.kdesdk_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.kdesdk+=	include/kbabel/*
BUILDLINK_FILES.kdesdk+=	include/kspy.h
BUILDLINK_FILES.kdesdk+=	lib/kde3/libdbsearchengine.*
BUILDLINK_FILES.kdesdk+=	lib/kde3/libkomparepart.*
BUILDLINK_FILES.kdesdk+=	lib/kde3/libpoauxiliary.*
BUILDLINK_FILES.kdesdk+=	lib/kde3/libpocompendium.*
BUILDLINK_FILES.kdesdk+=	lib/kde3/pothumbnail.*
BUILDLINK_FILES.kdesdk+=	lib/libcatalogmanager.*
BUILDLINK_FILES.kdesdk+=	lib/libcervisia.*
BUILDLINK_FILES.kdesdk+=	lib/libkbabel.*
BUILDLINK_FILES.kdesdk+=	lib/libkbabelcommon.*
BUILDLINK_FILES.kdesdk+=	lib/libkbabeldict.*
BUILDLINK_FILES.kdesdk+=	lib/libkbabeldictplugin.*
BUILDLINK_FILES.kdesdk+=	lib/libkspy.*

.include "../../databases/db/buildlink2.mk"
.include "../../devel/libtool/buildlink2.mk"
.include "../../x11/kde3/buildlink2.mk"
.include "../../x11/kdebase3/buildlink2.mk"

BUILDLINK_TARGETS+=	kdesdk-buildlink

kdesdk-buildlink: _BUILDLINK_USE

.endif	# KDESDK_BUILDLINK2_MK
