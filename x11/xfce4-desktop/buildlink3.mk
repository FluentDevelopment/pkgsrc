# $NetBSD: buildlink3.mk,v 1.12 2006/02/17 06:49:26 martti Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
XFCE4_DESKTOP_BUILDLINK3_MK:=	${XFCE4_DESKTOP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-desktop
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-desktop}
BUILDLINK_PACKAGES+=	xfce4-desktop

.if !empty(XFCE4_DESKTOP_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.xfce4-desktop+=	xfce4-desktop>=4.2.3
BUILDLINK_RECOMMENDED.xfce4-desktop?=	xfce4-desktop>=4.2.3nb2
BUILDLINK_PKGSRCDIR.xfce4-desktop?=	../../x11/xfce4-desktop
.endif	# XFCE4_DESKTOP_BUILDLINK3_MK

.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
