# $NetBSD: buildlink2.mk,v 1.4 2003/12/13 19:22:13 jmmv Exp $
#
# This Makefile fragment is included by packages that use xscreensaver.
#
# This file was created automatically using createbuildlink 2.6.
#

.if !defined(XSCREENSAVER_BUILDLINK2_MK)
XSCREENSAVER_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xscreensaver
BUILDLINK_DEPENDS.xscreensaver?=		xscreensaver>=4.14
BUILDLINK_PKGSRCDIR.xscreensaver?=		../../x11/xscreensaver

EVAL_PREFIX+=	BUILDLINK_PREFIX.xscreensaver=xscreensaver
BUILDLINK_PREFIX.xscreensaver_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.xscreensaver+=	lib/X11/app-defaults/XScreenSaver

.include "../../textproc/libxml2/buildlink2.mk"
.include "../../graphics/gle/buildlink2.mk"
.include "../../graphics/jpeg/buildlink2.mk"

BUILDLINK_TARGETS+=	xscreensaver-buildlink

xscreensaver-buildlink: _BUILDLINK_USE

.endif	# XSCREENSAVER_BUILDLINK2_MK
