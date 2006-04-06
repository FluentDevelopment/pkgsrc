# $NetBSD: buildlink3.mk,v 1.5 2006/04/06 06:22:35 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
YAZ_BUILDLINK3_MK:=	${YAZ_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	yaz
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nyaz}
BUILDLINK_PACKAGES+=	yaz

.if !empty(YAZ_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.yaz+=	yaz>=2.0
BUILDLINK_ABI_DEPENDS.yaz+=	yaz>=2.1.6nb1
BUILDLINK_PKGSRCDIR.yaz?=	../../net/yaz
.endif	# YAZ_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}

.include "../../textproc/libxml2/buildlink3.mk"
.include "../../converters/libiconv/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
