# $NetBSD: buildlink3.mk,v 1.13 2006/10/12 09:24:19 martti Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_DISKPERF_PLUGIN_BUILDLINK3_MK:=	${XFCE4_DISKPERF_PLUGIN_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xfce4-diskperf-plugin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-diskperf-plugin}
BUILDLINK_PACKAGES+=	xfce4-diskperf-plugin
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xfce4-diskperf-plugin

.if ${XFCE4_DISKPERF_PLUGIN_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.xfce4-diskperf-plugin+=	xfce4-diskperf-plugin>=1.5nb3
BUILDLINK_PKGSRCDIR.xfce4-diskperf-plugin?=	../../sysutils/xfce4-diskperf-plugin
.endif	# XFCE4_DISKPERF_PLUGIN_BUILDLINK3_MK

.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
