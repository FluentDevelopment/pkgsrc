# $NetBSD: buildlink2.mk,v 1.6 2003/09/01 15:31:14 jlam Exp $

.if !defined(LIBNBCOMPAT_BUILDLINK2_MK)
LIBNBCOMPAT_BUILDLINK2_MK=     # defined

BUILDLINK_DEPENDS.libnbcompat?=		libnbcompat>=20030823
BUILDLINK_PKGSRCDIR.libnbcompat?=	../../pkgtools/libnbcompat
BUILDLINK_DEPMETHOD.libnbcompat?=	build

BUILDLINK_PACKAGES+=		libnbcompat
EVAL_PREFIX+=			BUILDLINK_PREFIX.libnbcompat=libnbcompat
BUILDLINK_PREFIX.libnbcompat_DEFAULT=	${LOCALBASE}

BUILDLINK_FILES.libnbcompat+=	include/libnbcompat/*
BUILDLINK_FILES.libnbcompat+=	lib/libnbcompat.*

BUILDLINK_CPPFLAGS.libnbcompat=	\
	-I${BUILDLINK_PREFIX.libnbcompat}/include/libnbcompat

BUILDLINK_TARGETS+=	libnbcompat-buildlink

libnbcompat-buildlink: _BUILDLINK_USE

.endif  # LIBNBCOMPAT_BUILDLINK2_MK
