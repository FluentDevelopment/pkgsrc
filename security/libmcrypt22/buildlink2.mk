# $NetBSD: buildlink2.mk,v 1.3 2002/09/23 09:22:15 jlam Exp $

.if !defined(LIBMCRYPT22_BUILDLINK2_MK)
LIBMCRYPT22_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libmcrypt22
BUILDLINK_DEPENDS.libmcrypt22?=		libmcrypt22>=2.2.7
BUILDLINK_PKGSRCDIR.libmcrypt22?=	../../security/libmcrypt22

EVAL_PREFIX+=	BUILDLINK_PREFIX.libmcrypt22=libmcrypt22
BUILDLINK_PREFIX.libmcrypt22_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libmcrypt22=	include/libmcrypt22/mcrypt.h
BUILDLINK_FILES.libmcrypt22+=	lib/libmcrypt22.*
BUILDLINK_TRANSFORM+=			l:mcrypt:mcrypt22

BUILDLINK_CPPFLAGS.libmcrypt22= \
	-I${BUILDLINK_PREFIX.libmcrypt22}/include/libmcrypt22
CPPFLAGS+=	${BUILDLINK_CPPFLAGS.libmcrypt22}

BUILDLINK_TARGETS+=	libmcrypt22-buildlink

libmcrypt22-buildlink: _BUILDLINK_USE

.endif	# LIBMCRYPT22_BUILDLINK2_MK
