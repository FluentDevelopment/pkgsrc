# $NetBSD: buildlink3.mk,v 1.3 2004/03/18 09:12:12 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
JASPER_BUILDLINK3_MK:=	${JASPER_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	jasper
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Njasper}
BUILDLINK_PACKAGES+=	jasper

.if !empty(JASPER_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.jasper+=	jasper>=1.600.0
BUILDLINK_PKGSRCDIR.jasper?=	../../graphics/jasper
.endif	# JASPER_BUILDLINK3_MK

.include "../../graphics/jpeg/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
