# $NetBSD: buildlink3.mk,v 1.6 2006/02/05 23:11:39 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LESSTIF_BUILDLINK3_MK:=	${LESSTIF_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	lesstif
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlesstif}
BUILDLINK_PACKAGES+=	lesstif

.if !empty(LESSTIF_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.lesstif+=	lesstif>=0.91.4
BUILDLINK_RECOMMENDED.lesstif+=	lesstif>=0.94.4nb2
BUILDLINK_PKGSRCDIR.lesstif?=	../../x11/lesstif
.endif	# LESSTIF_BUILDLINK3_MK

.include "../../fonts/fontconfig/buildlink3.mk"
.include "../../x11/Xrender/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
