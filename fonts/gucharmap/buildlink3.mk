# $NetBSD: buildlink3.mk,v 1.1 2004/02/15 23:47:51 wiz Exp $
#
# This Makefile fragment is included by packages that use gucharmap.
#
# This file was created automatically using createbuildlink-3.1.
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GUCHARMAP_BUILDLINK3_MK:=	${GUCHARMAP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gucharmap
.endif

.if !empty(GUCHARMAP_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=			gucharmap
BUILDLINK_DEPENDS.gucharmap+=		gucharmap>=1.2.0nb2
BUILDLINK_PKGSRCDIR.gucharmap?=		../../fonts/gucharmap

.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../devel/popt/buildlink3.mk"

.endif # GUCHARMAP_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
