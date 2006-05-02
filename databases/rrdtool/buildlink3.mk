# $NetBSD: buildlink3.mk,v 1.12 2006/05/02 09:08:32 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
RRDTOOL_BUILDLINK3_MK:=	${RRDTOOL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	rrdtool
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nrrdtool}
BUILDLINK_PACKAGES+=	rrdtool

.if !empty(RRDTOOL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.rrdtool+=	rrdtool>=1.2.9
BUILDLINK_ABI_DEPENDS.rrdtool+=	rrdtool>=1.2.12nb3
BUILDLINK_PKGSRCDIR.rrdtool?=	../../databases/rrdtool
.endif	# RRDTOOL_BUILDLINK3_MK

.include "../../graphics/freetype-lib/buildlink3.mk"
.include "../../graphics/gd/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"
.include "../../graphics/libart2/buildlink3.mk"
.include "../../www/cgilib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
