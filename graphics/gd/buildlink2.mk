# $NetBSD: buildlink2.mk,v 1.4 2004/01/13 01:41:07 simonb Exp $

.if !defined(GD_BUILDLINK2_MK)
GD_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gd
BUILDLINK_DEPENDS.gd?=		gd>=2.0.15
BUILDLINK_PKGSRCDIR.gd?=	../../graphics/gd

EVAL_PREFIX+=		BUILDLINK_PREFIX.gd=gd
BUILDLINK_PREFIX.gd_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gd+=	include/gd*.h
BUILDLINK_FILES.gd+=	lib/libgd.*

.include "../../mk/pthread.buildlink2.mk"
.include "../../devel/zlib/buildlink2.mk"
.include "../../graphics/freetype2/buildlink2.mk"
.include "../../graphics/jpeg/buildlink2.mk"
.include "../../graphics/png/buildlink2.mk"
.include "../../graphics/xpm/buildlink2.mk"

BUILDLINK_TARGETS+=	gd-buildlink

gd-buildlink: _BUILDLINK_USE

.endif	# GD_BUILDLINK2_MK
