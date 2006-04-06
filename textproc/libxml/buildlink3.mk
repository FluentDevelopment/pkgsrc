# $NetBSD: buildlink3.mk,v 1.7 2006/04/06 06:22:51 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBXML_BUILDLINK3_MK:=	${LIBXML_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libxml
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibxml}
BUILDLINK_PACKAGES+=	libxml

.if !empty(LIBXML_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libxml+=	libxml>=1.8.11
BUILDLINK_ABI_DEPENDS.libxml+=	libxml>=1.8.17nb3
BUILDLINK_FILES.libxml+=	include/gnome-xml/libxml/*.h
BUILDLINK_PKGSRCDIR.libxml?=	../../textproc/libxml
.endif	# LIBXML_BUILDLINK3_MK

.include "../../devel/zlib/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
