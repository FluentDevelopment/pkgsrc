# $NetBSD: buildlink2.mk,v 1.5 2003/11/12 01:31:47 salo Exp $

.if !defined(GCONF_BUILDLINK2_MK)
GCONF_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gconf
BUILDLINK_DEPENDS.gconf?=	GConf>=1.0.9nb4
BUILDLINK_PKGSRCDIR.gconf?=	../../devel/GConf

EVAL_PREFIX+=			BUILDLINK_PREFIX.gconf=GConf
BUILDLINK_PREFIX.gconf_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.gconf=		include/gconf/1/gconf/*
BUILDLINK_FILES.gconf+=		lib/libgconf-*

.include "../../databases/db3/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../devel/oaf/buildlink2.mk"

BUILDLINK_TARGETS+=	gconf-buildlink

gconf-buildlink: _BUILDLINK_USE

.endif	# GCONF_BUILDLINK2_MK
