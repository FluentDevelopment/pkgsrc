# $NetBSD: buildlink2.mk,v 1.5 2003/12/05 09:55:46 adam Exp $
#

.if !defined(GNUSTEP_BASE_BUILDLINK2_MK)
GNUSTEP_BASE_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			gnustep-base
BUILDLINK_DEPENDS.gnustep-base?=	gnustep-base>=1.8.0
BUILDLINK_PKGSRCDIR.gnustep-base?=	../../devel/gnustep-base

EVAL_PREFIX+=	BUILDLINK_PREFIX.gnustep-base=gnustep-base
BUILDLINK_PREFIX.gnustep-base_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gnustep-base+=	share/GNUstep/System/Library/Headers/*
BUILDLINK_FILES.gnustep-base+=	share/GNUstep/System/Library/Headers/Foundation/*
BUILDLINK_FILES.gnustep-base+=	share/GNUstep/System/Library/Headers/GNUstepBase/*
BUILDLINK_FILES.gnustep-base+=	share/GNUstep/System/Library/Headers/gnustep/base/*
BUILDLINK_FILES.gnustep-base+=	share/GNUstep/System/Library/Headers/gnustep/unicode/*
BUILDLINK_FILES.gnustep-base+=	share/GNUstep/System/Library/Libraries/libgnustep-base.*

.include "../../converters/libiconv/buildlink2.mk"
.include "../../devel/ffcall/buildlink2.mk"
.include "../../devel/gmp/buildlink2.mk"
.include "../../devel/gnustep-objc/buildlink2.mk"
.include "../../security/openssl/buildlink2.mk"
.include "../../textproc/libxml2/buildlink2.mk"

BUILDLINK_TARGETS+=	gnustep-base-buildlink

gnustep-base-buildlink: _BUILDLINK_USE

.endif	# GNUSTEP_BASE_BUILDLINK2_MK
