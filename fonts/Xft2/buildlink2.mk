# $NetBSD: buildlink2.mk,v 1.3 2002/12/24 00:43:42 wiz Exp $
#
# This Makefile fragment is included by packages that use Xft2.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(XFT2_BUILDLINK2_MK)
XFT2_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			Xft2
BUILDLINK_DEPENDS.Xft2?=		Xft2>=2.1nb1
BUILDLINK_PKGSRCDIR.Xft2?=		../../fonts/Xft2

EVAL_PREFIX+=	BUILDLINK_PREFIX.Xft2=Xft2
BUILDLINK_PREFIX.Xft2_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.Xft2+=	include/X11/Xft/*
BUILDLINK_FILES.Xft2+=	lib/libXft.*
BUILDLINK_FILES.Xft2+=	lib/pkgconfig/xft.pc

.include "../../graphics/freetype2/buildlink2.mk"
.include "../../fonts/fontconfig/buildlink2.mk"

BUILDLINK_TARGETS+=	Xft2-buildlink

Xft2-buildlink: _BUILDLINK_USE

.endif	# XFT2_BUILDLINK2_MK
