# $NetBSD: buildlink3.mk,v 1.1 2004/05/05 03:36:25 snj Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
RENDERKIT_BUILDLINK3_MK:=	${RENDERKIT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	RenderKit
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NRenderKit}
BUILDLINK_PACKAGES+=	RenderKit

.if !empty(RENDERKIT_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.RenderKit+=	RenderKit>=0.3.1r2nb3
BUILDLINK_RECOMMENDED.RenderKit?=	RenderKit>=0.3.1r2nb5
BUILDLINK_PKGSRCDIR.RenderKit?=	../../graphics/RenderKit
.endif	# RENDERKIT_BUILDLINK3_MK

.include "../../graphics/GeometryKit/buildlink3.mk"
.include "../../graphics/MesaLib/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
