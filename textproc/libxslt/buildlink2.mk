# $NetBSD: buildlink2.mk,v 1.7 2003/02/24 20:45:19 jmmv Exp $

.if !defined(LIBXSLT_BUILDLINK2_MK)
LIBXSLT_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		libxslt
BUILDLINK_DEPENDS.libxslt?=	libxslt>=1.0.26
BUILDLINK_PKGSRCDIR.libxslt?=	../../textproc/libxslt

EVAL_PREFIX+=	BUILDLINK_PREFIX.libxslt=libxslt
BUILDLINK_PREFIX.libxslt_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libxslt=	include/breakpoint/*
BUILDLINK_FILES.libxslt+=	include/libexslt/*
BUILDLINK_FILES.libxslt+=	include/libxslt/*
BUILDLINK_FILES.libxslt+=	lib/libexslt.*
BUILDLINK_FILES.libxslt+=	lib/libxslt.*
BUILDLINK_FILES.libxslt+=	lib/libxsltbreakpoint.*

.include "../../textproc/libxml2/buildlink2.mk"

BUILDLINK_TARGETS+=	libxslt-buildlink

libxslt-buildlink: _BUILDLINK_USE

.endif	# LIBXSLT_BUILDLINK2_MK
