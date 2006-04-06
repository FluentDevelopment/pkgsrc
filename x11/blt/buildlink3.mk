# $NetBSD: buildlink3.mk,v 1.8 2006/04/06 06:22:57 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
BLT_BUILDLINK3_MK:=	${BLT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	blt
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nblt}
BUILDLINK_PACKAGES+=	blt

.if !empty(BLT_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.blt+=		blt>=2.4z
BUILDLINK_ABI_DEPENDS.blt?=	blt>=2.4znb2
BUILDLINK_PKGSRCDIR.blt?=	../../x11/blt
.endif	# BLT_BUILDLINK3_MK

.include "../../lang/tcl/buildlink3.mk"
.include "../../x11/tk/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
