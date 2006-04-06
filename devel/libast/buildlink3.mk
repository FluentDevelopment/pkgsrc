# $NetBSD: buildlink3.mk,v 1.6 2006/04/06 06:21:50 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBAST_BUILDLINK3_MK:=	${LIBAST_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libast
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibast}
BUILDLINK_PACKAGES+=	libast

.if !empty(LIBAST_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libast+=	libast>=0.5nb5
BUILDLINK_ABI_DEPENDS.libast+=	libast>=0.6.1nb1
BUILDLINK_PKGSRCDIR.libast?=	../../devel/libast
.endif	# LIBAST_BUILDLINK3_MK

.include "../../devel/pcre/buildlink3.mk"
.include "../../graphics/imlib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
