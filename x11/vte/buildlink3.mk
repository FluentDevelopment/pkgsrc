# $NetBSD: buildlink3.mk,v 1.5 2004/05/07 11:13:16 jmmv Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
VTE_BUILDLINK3_MK:=	${VTE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	vte
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nvte}
BUILDLINK_PACKAGES+=	vte

.if !empty(VTE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.vte+=		vte>=0.11.11
BUILDLINK_PKGSRCDIR.vte?=	../../x11/vte
.endif	# VTE_BUILDLINK3_MK

.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/libzvt/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
