# $NetBSD: buildlink3.mk,v 1.9 2006/07/08 22:39:41 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBXML_BUILDLINK3_MK:=	${LIBXML_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libxml
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibxml}
BUILDLINK_PACKAGES+=	libxml
BUILDLINK_ORDER+=	libxml

.if !empty(LIBXML_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libxml+=	libxml>=1.8.11
BUILDLINK_ABI_DEPENDS.libxml+=	libxml>=1.8.17nb3
BUILDLINK_FILES.libxml+=	include/gnome-xml/libxml/*.h
BUILDLINK_PKGSRCDIR.libxml?=	../../textproc/libxml
.endif	# LIBXML_BUILDLINK3_MK

.include "../../devel/zlib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
