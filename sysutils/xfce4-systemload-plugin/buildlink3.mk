# $NetBSD: buildlink3.mk,v 1.6 2006/01/24 07:32:36 wiz Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_SYSTEMLOAD_PLUGIN_BUILDLINK3_MK:=	${XFCE4_SYSTEMLOAD_PLUGIN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-systemload-plugin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-systemload-plugin}
BUILDLINK_PACKAGES+=	xfce4-systemload-plugin

.if !empty(XFCE4_SYSTEMLOAD_PLUGIN_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.xfce4-systemload-plugin+=	xfce4-systemload-plugin>=0.3.6
BUILDLINK_RECOMMENDED.xfce4-systemload-plugin?=	xfce4-systemload-plugin>=0.3.6nb2
BUILDLINK_PKGSRCDIR.xfce4-systemload-plugin?=	../../sysutils/xfce4-systemload-plugin
.endif	# XFCE4_SYSTEMLOAD_PLUGIN_BUILDLINK3_MK

.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
