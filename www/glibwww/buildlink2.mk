# $NetBSD: buildlink2.mk,v 1.6 2004/03/16 11:04:19 tron Exp $

.if !defined(GLIBWWW_BUILDLINK2_MK)
GLIBWWW_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		glibwww
BUILDLINK_DEPENDS.glibwww?=	glibwww>=0.2nb5
BUILDLINK_PKGSRCDIR.glibwww?=	../../www/glibwww

EVAL_PREFIX+=			BUILDLINK_PREFIX.glibwww=glibwww
BUILDLINK_PREFIX.glibwww_DEFAULTS=	${X11PREFIX}
BUILDLINK_FILES.glibwww=	include/glibwww/glibwww.h
BUILDLINK_FILES.glibwww+=	lib/libglibwww.*

.include "../../databases/db4/buildlink2.mk"
.include "../../www/libwww/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"

BUILDLINK_TARGETS+=	glibwww-buildlink

glibwww-buildlink: _BUILDLINK_USE

.endif	# GLIBWWW_BUILDLINK2_MK
