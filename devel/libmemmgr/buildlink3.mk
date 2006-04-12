# $NetBSD: buildlink3.mk,v 1.3 2006/04/12 10:27:11 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBMEMMGR_BUILDLINK3_MK:=	${LIBMEMMGR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libmemmgr
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibmemmgr}
BUILDLINK_PACKAGES+=	libmemmgr

.if !empty(LIBMEMMGR_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libmemmgr+=	libmemmgr>=1.04
BUILDLINK_PKGSRCDIR.libmemmgr?=	../../devel/libmemmgr
BUILDLINK_DEPMETHOD.libmemmgr?=	build
.endif	# LIBMEMMGR_BUILDLINK3_MK

.include "../../devel/libetm/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
