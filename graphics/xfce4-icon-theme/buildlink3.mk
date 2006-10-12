# $NetBSD: buildlink3.mk,v 1.11 2006/10/12 09:24:19 martti Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_ICON_THEME_BUILDLINK3_MK:=	${XFCE4_ICON_THEME_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xfce4-icon-theme
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-icon-theme}
BUILDLINK_PACKAGES+=	xfce4-icon-theme
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xfce4-icon-theme

.if ${XFCE4_ICON_THEME_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.xfce4-icon-theme+=	xfce4-icon-theme>=4.2.3nb1
BUILDLINK_PKGSRCDIR.xfce4-icon-theme?=	../../graphics/xfce4-icon-theme
.endif	# XFCE4_ICON_THEME_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
