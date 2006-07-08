# $NetBSD: buildlink3.mk,v 1.11 2006/07/08 22:39:45 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GTKMM_BUILDLINK3_MK:=	${GTKMM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gtkmm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngtkmm}
BUILDLINK_PACKAGES+=	gtkmm
BUILDLINK_ORDER+=	gtkmm

.if !empty(GTKMM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gtkmm+=	gtkmm>=2.6.3
BUILDLINK_ABI_DEPENDS.gtkmm+=	gtkmm>=2.8.4nb1
BUILDLINK_PKGSRCDIR.gtkmm?=	../../x11/gtkmm
.endif	# GTKMM_BUILDLINK3_MK

.include "../../devel/glibmm/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
