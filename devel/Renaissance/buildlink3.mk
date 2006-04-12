# $NetBSD: buildlink3.mk,v 1.6 2006/04/12 10:27:06 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
RENAISSANCE_BUILDLINK3_MK:=	${RENAISSANCE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	Renaissance
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NRenaissance}
BUILDLINK_PACKAGES+=	Renaissance

.if !empty(RENAISSANCE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.Renaissance+=		Renaissance>=0.7.0
BUILDLINK_ABI_DEPENDS.Renaissance+=	Renaissance>=0.8.0nb4
BUILDLINK_PKGSRCDIR.Renaissance?=	../../devel/Renaissance
.endif	# RENAISSANCE_BUILDLINK3_MK

.include "../../x11/gnustep-back/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
