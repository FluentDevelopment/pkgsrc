# $NetBSD: buildlink3.mk,v 1.2 2006/07/08 22:39:44 jlam Exp $

BUILDLINK_DEPMETHOD.fixesproto?=	build

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
FIXESPROTO_BUILDLINK3_MK:=	${FIXESPROTO_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	fixesproto
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nfixesproto}
BUILDLINK_PACKAGES+=	fixesproto
BUILDLINK_ORDER+=	fixesproto

.if !empty(FIXESPROTO_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.fixesproto+=	fixesproto>=3.0.0
BUILDLINK_PKGSRCDIR.fixesproto?=	../../x11/fixesproto
.endif	# FIXESPROTO_BUILDLINK3_MK

.include "../../x11/xextproto/buildlink3.mk"
.include "../../x11/xproto/buildlink3.mk"


BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
