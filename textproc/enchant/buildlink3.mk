# $NetBSD: buildlink3.mk,v 1.7 2006/04/06 06:22:50 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
ENCHANT_BUILDLINK3_MK:=	${ENCHANT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	enchant
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nenchant}
BUILDLINK_PACKAGES+=	enchant

.if !empty(ENCHANT_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.enchant+=	enchant>=1.1.3
BUILDLINK_ABI_DEPENDS.enchant+=	enchant>=1.1.6nb1
BUILDLINK_PKGSRCDIR.enchant?=	../../textproc/enchant
.endif	# ENCHANT_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"
.include "../../textproc/aspell/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
