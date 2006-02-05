# $NetBSD: buildlink3.mk,v 1.3 2006/02/05 23:10:57 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
VCDIMAGER_BUILDLINK3_MK:=	${VCDIMAGER_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	vcdimager
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nvcdimager}
BUILDLINK_PACKAGES+=	vcdimager

.if !empty(VCDIMAGER_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.vcdimager+=	vcdimager>=0.7.20
BUILDLINK_RECOMMENDED.vcdimager+=	vcdimager>=0.7.23nb1
BUILDLINK_PKGSRCDIR.vcdimager?=	../../sysutils/vcdimager-devel
.endif	# VCDIMAGER_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/popt/buildlink3.mk"
.include "../../misc/libcdio/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
