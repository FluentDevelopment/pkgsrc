# $NetBSD: buildlink2.mk,v 1.5 2003/12/13 00:45:22 wiz Exp $
#
# This Makefile fragment is included by packages that use gconfmm.
#
# This file was created automatically using createbuildlink 2.4.
#

.if !defined(GCONFMM_BUILDLINK2_MK)
GCONFMM_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			gconfmm
BUILDLINK_DEPENDS.gconfmm?=		gconfmm>=2.0.1nb4
BUILDLINK_PKGSRCDIR.gconfmm?=		../../devel/gconfmm

EVAL_PREFIX+=	BUILDLINK_PREFIX.gconfmm=gconfmm
BUILDLINK_PREFIX.gconfmm_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gconfmm+=	include/gconfmm-2.0/*
BUILDLINK_FILES.gconfmm+=	include/gconfmm-2.0/gconfmm/*
BUILDLINK_FILES.gconfmm+=	include/gconfmm-2.0/gconfmm/private/*
BUILDLINK_FILES.gconfmm+=	lib/gconfmm-2.0/include/*
BUILDLINK_FILES.gconfmm+=	lib/gconfmm-2.0/proc/m4/*
BUILDLINK_FILES.gconfmm+=	lib/libgconfmm-2.0.*
BUILDLINK_FILES.gconfmm+=	lib/pkgconfig/gconfmm-2.0.pc

.include "../../devel/GConf2/buildlink2.mk"
.include "../../devel/libsigc++/buildlink2.mk"
.include "../../devel/pkgconfig/buildlink2.mk"
.include "../../x11/gtkmm/buildlink2.mk"

BUILDLINK_TARGETS+=	gconfmm-buildlink

gconfmm-buildlink: _BUILDLINK_USE

.endif	# GCONFMM_BUILDLINK2_MK
