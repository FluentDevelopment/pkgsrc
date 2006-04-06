# $NetBSD: buildlink3.mk,v 1.5 2006/04/06 06:21:40 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
BDB_XML_BUILDLINK3_MK:=	${BDB_XML_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	bdb-xml
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nbdb-xml}
BUILDLINK_PACKAGES+=	bdb-xml

.if !empty(BDB_XML_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.bdb-xml+=	bdb-xml>=1.2.1nb3
BUILDLINK_ABI_DEPENDS.bdb-xml?=	bdb-xml>=1.2.1nb4
BUILDLINK_PKGSRCDIR.bdb-xml?=	../../databases/bdb-xml
.endif	# BDB_XML_BUILDLINK3_MK

.include "../../databases/db4/buildlink3.mk"
.include "../../textproc/libpathan/buildlink3.mk"
.include "../../textproc/xerces-c/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
