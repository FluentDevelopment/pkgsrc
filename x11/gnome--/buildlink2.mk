# $NetBSD: buildlink2.mk,v 1.7 2003/07/13 13:53:55 wiz Exp $

.if !defined(GNOMEMM_BUILDLINK2_MK)
GNOMEMM_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gnomemm
BUILDLINK_DEPENDS.gnomemm?=	gnome-->=1.2.2nb3
BUILDLINK_PKGSRCDIR.gnomemm?=	../../x11/gnome--

EVAL_PREFIX+=				BUILDLINK_PREFIX.gnomemm=gnome--
BUILDLINK_PREFIX.gnomemm_DEFAULT=	${X11PREFIX}

BUILDLINK_FILES.gnomemm=	include/gnome--/private/*
BUILDLINK_FILES.gnomemm+=	include/gnome--/*
BUILDLINK_FILES.gnomemm+=	include/gnome--.h
BUILDLINK_FILES.gnomemm+=	lib/libgnomemm-1.1.*
BUILDLINK_FILES.gnomemm+=	lib/libgnomemm.*

.include "../../devel/libsigc++10/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"
.include "../../x11/gtk--/buildlink2.mk"

BUILDLINK_TARGETS+=	gnomemm-buildlink

gnomemm-buildlink: _BUILDLINK_USE

.endif	# GNOMEMM_BUILDLINK2_MK
