# $NetBSD: buildlink3.mk,v 1.4 2004/03/18 09:12:14 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PDFLIB_BUILDLINK3_MK:=	${PDFLIB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pdflib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npdflib}
BUILDLINK_PACKAGES+=	pdflib

.if !empty(PDFLIB_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.pdflib+=	pdflib>=4.0.3nb2
BUILDLINK_PKGSRCDIR.pdflib?=	../../print/pdflib
.endif	# PDFLIB_BUILDLINK3_MK

.include "../../graphics/png/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
