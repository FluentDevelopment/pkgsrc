# $NetBSD: buildlink2.mk,v 1.3 2003/12/13 00:45:24 wiz Exp $
#
# This Makefile fragment is included by packages that use xfce4-artwork.
#
# This file was created automatically using createbuildlink 2.7.
#

.if !defined(XFCE4_ARTWORK_BUILDLINK2_MK)
XFCE4_ARTWORK_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xfce4-artwork
BUILDLINK_DEPENDS.xfce4-artwork?=		xfce4-artwork>=0.0.4nb1
BUILDLINK_PKGSRCDIR.xfce4-artwork?=		../../graphics/xfce4-artwork

EVAL_PREFIX+=	BUILDLINK_PREFIX.xfce4-artwork=xfce4-artwork
BUILDLINK_PREFIX.xfce4-artwork_DEFAULT=	${X11PREFIX}

.include "../../x11/xfce4-desktop/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"

BUILDLINK_TARGETS+=	xfce4-artwork-buildlink

xfce4-artwork-buildlink: _BUILDLINK_USE

.endif	# XFCE4_ARTWORK_BUILDLINK2_MK
