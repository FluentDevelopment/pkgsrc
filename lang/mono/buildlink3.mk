# $NetBSD: buildlink3.mk,v 1.4 2004/03/05 19:25:36 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
MONO_BUILDLINK3_MK:=	${MONO_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	mono
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmono}
BUILDLINK_PACKAGES+=	mono

.if !empty(MONO_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.mono+=	mono>=0.30
BUILDLINK_PKGSRCDIR.mono?=	../../lang/mono

.include "../../devel/glib2/buildlink3.mk"
.include "../../textproc/icu/buildlink3.mk"

.endif	# MONO_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
