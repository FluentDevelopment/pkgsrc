# $NetBSD: buildlink2.mk,v 1.7 2004/02/06 18:41:02 minskim Exp $

.if !defined(INTLTOOL_BUILDLINK2_MK)
INTLTOOL_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		intltool
BUILDLINK_DEPENDS.intltool?=	intltool>=0.30
BUILDLINK_PKGSRCDIR.intltool?=	../../textproc/intltool
BUILDLINK_DEPMETHOD.intltool?=	build

EVAL_PREFIX+=	BUILDLINK_PREFIX.intltool=intltool
BUILDLINK_PREFIX.intltool_DEFAULT=	${LOCALBASE}

USE_PERL5?=	build
.include "../../lang/perl5/buildlink2.mk"

BUILDLINK_TARGETS+=	intltool-buildlink

intltool-buildlink: _BUILDLINK_USE

.endif	# INTLTOOL_BUILDLINK2_MK
