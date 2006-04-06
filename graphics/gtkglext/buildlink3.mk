# $NetBSD: buildlink3.mk,v 1.10 2006/04/06 06:22:03 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GTKGLEXT_BUILDLINK3_MK:=	${GTKGLEXT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gtkglext
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngtkglext}
BUILDLINK_PACKAGES+=	gtkglext

.if !empty(GTKGLEXT_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gtkglext+=	gtkglext>=1.2.0
BUILDLINK_PKGSRCDIR.gtkglext?=	../../graphics/gtkglext
.endif	# GTKGLEXT_BUILDLINK3_MK

.include "../../graphics/glu/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
