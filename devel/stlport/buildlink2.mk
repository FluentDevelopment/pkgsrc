# $NetBSD: buildlink2.mk,v 1.5 2002/10/01 00:11:54 jlam Exp $

.if !defined(STLPORT_BUILDLINK2_MK)
STLPORT_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		stlport
BUILDLINK_DEPENDS.stlport?=	stlport>=4.0nb1
BUILDLINK_PKGSRCDIR.stlport?=	../../devel/stlport
BUILDLINK_DEPMETHOD.stlport?=	build

EVAL_PREFIX+=			BUILDLINK_PREFIX.stlport=stlport
BUILDLINK_PREFIX.stlport_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.stlport=	include/stlport/*
BUILDLINK_FILES.stlport+=	include/stlport/*/*
BUILDLINK_FILES.stlport+=	lib/libstlport*

BUILDLINK_CPPFLAGS.stlport=	-I${BUILDLINK_PREFIX.stlport}/include/stlport

BUILDLINK_TARGETS+=	stlport-buildlink

stlport-buildlink: _BUILDLINK_USE

.endif	# STLPORT_BUILDLINK2_MK
