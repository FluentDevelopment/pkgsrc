# $NetBSD: buildlink2.mk,v 1.3 2002/11/11 21:28:27 wiz Exp $

.if !defined(JASPER_BUILDLINK2_MK)
JASPER_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		jasper
BUILDLINK_DEPENDS.jasper?=	jasper>=1.500.0
BUILDLINK_PKGSRCDIR.jasper?=	../../graphics/jasper

EVAL_PREFIX+=		BUILDLINK_PREFIX.jasper=jasper
BUILDLINK_PREFIX.jasper_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.jasper=		include/jasper/*
BUILDLINK_FILES.jasper+=	lib/libjasper.*

BUILDLINK_TARGETS+=	jasper-buildlink

jasper-buildlink: _BUILDLINK_USE

.endif	# JASPER_BUILDLINK2_MK
