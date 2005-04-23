# $NetBSD: buildlink3.mk,v 1.7 2005/04/23 12:25:05 shannonjr Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBKSBA_BUILDLINK3_MK:=	${LIBKSBA_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libksba
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibksba}
BUILDLINK_PACKAGES+=	libksba

.if !empty(LIBKSBA_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libksba+=	libksba>=0.9.7
BUILDLINK_RECOMMENDED.libksba+=	libksba>=0.9.11
BUILDLINK_PKGSRCDIR.libksba?=	../../security/libksba
.endif	# LIBKSBA_BUILDLINK3_MK

.include "../../security/libgcrypt/buildlink3.mk"
.include "../../security/libgpg-error/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
