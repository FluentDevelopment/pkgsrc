# $NetBSD: buildlink2.mk,v 1.8 2004/01/03 18:49:39 reed Exp $

.if !defined(OAF_BUILDLINK2_MK)
OAF_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		oaf
BUILDLINK_DEPENDS.oaf?=		oaf>=0.6.10nb4
BUILDLINK_PKGSRCDIR.oaf?=	../../devel/oaf

EVAL_PREFIX+=			BUILDLINK_PREFIX.oaf=oaf
BUILDLINK_PREFIX.oaf_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.oaf=		include/liboaf/*
BUILDLINK_FILES.oaf+=		lib/liboaf.*
BUILDLINK_FILES.oaf+=		share/idl/oaf*.idl

.include "../../devel/popt/buildlink2.mk"
.include "../../textproc/libxml/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"

BUILDLINK_TARGETS+=		oaf-buildlink

oaf-buildlink: _BUILDLINK_USE

.endif	# OAF_BUILDLINK2_MK
