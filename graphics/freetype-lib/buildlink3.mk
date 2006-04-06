# $NetBSD: buildlink3.mk,v 1.11 2006/04/06 06:22:02 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
FREETYPE_BUILDLINK3_MK:=	${FREETYPE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	freetype
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nfreetype}
BUILDLINK_PACKAGES+=	freetype

.if !empty(FREETYPE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.freetype+=	freetype-lib>=1.3.1nb1
BUILDLINK_ABI_DEPENDS.freetype+=freetype-lib>=1.3.1nb2
BUILDLINK_ABI_DEPENDS.freetype?=	freetype-lib>=1.3.1nb3
BUILDLINK_PKGSRCDIR.freetype?=	../../graphics/freetype-lib
.endif	# FREETYPE_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
