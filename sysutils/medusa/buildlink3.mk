# $NetBSD: buildlink3.mk,v 1.9 2006/07/08 22:39:39 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
MEDUSA_BUILDLINK3_MK:=	${MEDUSA_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	medusa
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmedusa}
BUILDLINK_PACKAGES+=	medusa
BUILDLINK_ORDER+=	medusa

.if !empty(MEDUSA_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.medusa+=	medusa>=0.5.1nb7
BUILDLINK_ABI_DEPENDS.medusa?=	medusa>=0.5.1nb10
BUILDLINK_PKGSRCDIR.medusa?=	../../sysutils/medusa
.endif	# MEDUSA_BUILDLINK3_MK

.include "../../sysutils/gnome-vfs/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
