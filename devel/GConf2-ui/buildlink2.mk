# $NetBSD: buildlink2.mk,v 1.7 2003/12/14 19:45:45 jmmv Exp $
#
# This Makefile fragment is included by packages that use GConf2-ui.
#

.if !defined(GCONF2_UI_BUILDLINK2_MK)
GCONF2_UI_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			GConf2-ui
BUILDLINK_DEPENDS.GConf2-ui?=		GConf2-ui>=2.4.0.1
BUILDLINK_PKGSRCDIR.GConf2-ui?=		../../devel/GConf2-ui

EVAL_PREFIX+=	BUILDLINK_PREFIX.GConf2-ui=GConf2-ui
BUILDLINK_PREFIX.GConf2-ui_DEFAULT=	${LOCALBASE}

.include "../../devel/GConf2/buildlink2.mk"

BUILDLINK_TARGETS+=	GConf2-ui-buildlink

GConf2-ui-buildlink: _BUILDLINK_USE

.endif	# GCONF2_UI_BUILDLINK2_MK
