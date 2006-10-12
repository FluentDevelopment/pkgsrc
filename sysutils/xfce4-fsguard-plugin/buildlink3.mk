# $NetBSD: buildlink3.mk,v 1.10 2006/10/12 09:24:19 martti Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_FSGUARD_PLUGIN_BUILDLINK3_MK:=	${XFCE4_FSGUARD_PLUGIN_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xfce4-fsguard-plugin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-fsguard-plugin}
BUILDLINK_PACKAGES+=	xfce4-fsguard-plugin
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xfce4-fsguard-plugin

.if ${XFCE4_FSGUARD_PLUGIN_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.xfce4-fsguard-plugin+=	xfce4-fsguard-plugin>=0.2.1nb3
BUILDLINK_PKGSRCDIR.xfce4-fsguard-plugin?=	../../sysutils/xfce4-fsguard-plugin
.endif	# XFCE4_FSGUARD_PLUGIN_BUILDLINK3_MK

.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
