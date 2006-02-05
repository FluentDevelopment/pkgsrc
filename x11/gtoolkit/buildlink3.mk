# $NetBSD: buildlink3.mk,v 1.6 2006/02/05 23:11:35 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GTOOLKIT_BUILDLINK3_MK:=	${GTOOLKIT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gtoolkit
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngtoolkit}
BUILDLINK_PACKAGES+=	gtoolkit

.if !empty(GTOOLKIT_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gtoolkit+=	gtoolkit>=0.9.5nb5
BUILDLINK_RECOMMENDED.gtoolkit+=gtoolkit>=0.9.5nb7
BUILDLINK_RECOMMENDED.gtoolkit?=	gtoolkit>=0.9.5nb9
BUILDLINK_PKGSRCDIR.gtoolkit?=	../../x11/gtoolkit
.endif	# GTOOLKIT_BUILDLINK3_MK

.include "../../x11/gtk/buildlink3.mk"
.include "../../x11/gnustep-back/buildlink3.mk"
.include "../../devel/libglade/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
