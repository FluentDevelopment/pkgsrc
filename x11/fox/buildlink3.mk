# $NetBSD: buildlink3.mk,v 1.2 2004/03/18 09:12:16 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
FOX_BUILDLINK3_MK:=	${FOX_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	fox
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nfox}
BUILDLINK_PACKAGES+=	fox

.if !empty(FOX_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.fox+=		fox>=1.0.43nb2
BUILDLINK_PKGSRCDIR.fox?=	../../x11/fox
BUILDLINK_INCDIRS.fox?=		include/fox
.endif	# FOX_BUILDLINK3_MK

.include "../../graphics/jpeg/buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"
.include "../../graphics/MesaLib/buildlink3.mk"
.include "../../graphics/glu/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
