# $NetBSD: buildlink3.mk,v 1.4 2006/04/12 10:27:40 rillig Exp $
#
# This Makefile fragment is included by packages that use compositeext.
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
COMPOSITEEXT_BUILDLINK3_MK:=	${COMPOSITEEXT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	compositeext
.endif

.if !empty(COMPOSITEEXT_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=			compositeext
BUILDLINK_API_DEPENDS.compositeext?=	compositeext>=2.0
BUILDLINK_ABI_DEPENDS.compositeext?=	compositeext>=2.0nb1
BUILDLINK_PKGSRCDIR.compositeext?=	../../x11/compositeext

.include "../../x11/fixesext/buildlink3.mk"
.include "../../x11/xextensions/buildlink3.mk"

.endif # COMPOSITEEXT_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
