# $NetBSD: buildlink2.mk,v 1.2 2002/12/24 06:10:07 wiz Exp $
#

.if !defined(LIBRSVG_BUILDLINK2_MK)
LIBRSVG_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			librsvg
BUILDLINK_DEPENDS.librsvg?=		librsvg>=1.0.1nb2
BUILDLINK_PKGSRCDIR.librsvg?=		../../graphics/librsvg

EVAL_PREFIX+=	BUILDLINK_PREFIX.librsvg=librsvg
BUILDLINK_PREFIX.librsvg_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.librsvg+=	include/librsvg/*.h
BUILDLINK_FILES.librsvg+=	lib/librsvg.*
BUILDLINK_FILES.librsvg+=	lib/librsvgConf.sh

.include "../../graphics/gdk-pixbuf/buildlink2.mk"
.include "../../graphics/freetype2/buildlink2.mk"
.include "../../textproc/libxml/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"

BUILDLINK_TARGETS+=	librsvg-buildlink

librsvg-buildlink: _BUILDLINK_USE

.endif	# LIBRSVG_BUILDLINK2_MK
