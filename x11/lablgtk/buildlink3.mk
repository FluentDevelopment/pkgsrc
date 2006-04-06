# $NetBSD: buildlink3.mk,v 1.5 2006/04/06 06:23:01 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LABLGTK_BUILDLINK3_MK:=	${LABLGTK_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	lablgtk
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlablgtk}
BUILDLINK_PACKAGES+=	lablgtk

.if !empty(LABLGTK_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.lablgtk+=	lablgtk>=1.2.5nb3
BUILDLINK_ABI_DEPENDS.lablgtk?=	lablgtk>=1.2.7nb2
BUILDLINK_PKGSRCDIR.lablgtk?=	../../x11/lablgtk
.endif	# LABLGTK_BUILDLINK3_MK

.include "../../x11/gtk/buildlink3.mk"
.include "../../lang/ocaml/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
