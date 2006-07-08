# $NetBSD: buildlink3.mk,v 1.8 2006/07/08 22:39:39 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GKRELLM_BUILDLINK3_MK:=	${GKRELLM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gkrellm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngkrellm}
BUILDLINK_PACKAGES+=	gkrellm
BUILDLINK_ORDER+=	gkrellm

.if !empty(GKRELLM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gkrellm+=	gkrellm<2.0
BUILDLINK_ABI_DEPENDS.gkrellm?=	gkrellm>=1.2.13nb6
BUILDLINK_PKGSRCDIR.gkrellm?=	../../sysutils/gkrellm1
.endif	# GKRELLM_BUILDLINK3_MK

.include "../../graphics/imlib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
