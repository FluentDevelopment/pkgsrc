# $NetBSD: buildlink3.mk,v 1.8 2004/03/26 02:27:50 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CUPS_BUILDLINK3_MK:=	${CUPS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cups
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncups}
BUILDLINK_PACKAGES+=	cups

.if !empty(CUPS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cups+=	cups>=1.1.19nb3
BUILDLINK_RECOMMENDED.cups?=	cups>=1.1.20nb1
BUILDLINK_PKGSRCDIR.cups?=	../../print/cups
.endif	# CUPS_BUILDLINK3_MK

.include "../../graphics/png/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
