# $NetBSD: buildlink3.mk,v 1.6 2006/04/12 10:27:20 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GAUCHE_BUILDLINK3_MK:=	${GAUCHE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	Gauche
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NGauche}
BUILDLINK_PACKAGES+=	Gauche

.if !empty(GAUCHE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.Gauche+=	Gauche>=0.8.1
BUILDLINK_PKGSRCDIR.Gauche?=	../../lang/gauche
.endif	# GAUCHE_BUILDLINK3_MK

.include "../../converters/libiconv/buildlink3.mk"
.include "../../mk/dlopen.buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
