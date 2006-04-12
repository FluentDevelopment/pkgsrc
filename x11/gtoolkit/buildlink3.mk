# $NetBSD: buildlink3.mk,v 1.8 2006/04/12 10:27:41 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GTOOLKIT_BUILDLINK3_MK:=	${GTOOLKIT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gtoolkit
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngtoolkit}
BUILDLINK_PACKAGES+=	gtoolkit

.if !empty(GTOOLKIT_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gtoolkit+=	gtoolkit>=0.9.5nb5
BUILDLINK_ABI_DEPENDS.gtoolkit+=gtoolkit>=0.9.5nb7
BUILDLINK_ABI_DEPENDS.gtoolkit?=	gtoolkit>=0.9.5nb9
BUILDLINK_PKGSRCDIR.gtoolkit?=	../../x11/gtoolkit
.endif	# GTOOLKIT_BUILDLINK3_MK

.include "../../x11/gtk/buildlink3.mk"
.include "../../x11/gnustep-back/buildlink3.mk"
.include "../../devel/libglade/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
