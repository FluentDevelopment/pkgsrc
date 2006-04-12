# $NetBSD: buildlink3.mk,v 1.8 2006/04/12 10:27:36 rillig Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_CPUGRAPH_PLUGIN_BUILDLINK3_MK:=	${XFCE4_CPUGRAPH_PLUGIN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-cpugraph-plugin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-cpugraph-plugin}
BUILDLINK_PACKAGES+=	xfce4-cpugraph-plugin

.if !empty(XFCE4_CPUGRAPH_PLUGIN_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.xfce4-cpugraph-plugin+=	xfce4-cpugraph-plugin>=0.2.2nb1
BUILDLINK_ABI_DEPENDS.xfce4-cpugraph-plugin?=	xfce4-cpugraph-plugin>=0.2.2nb3
BUILDLINK_PKGSRCDIR.xfce4-cpugraph-plugin?=	../../sysutils/xfce4-cpugraph-plugin
.endif	# XFCE4_CPUGRAPH_PLUGIN_BUILDLINK3_MK

.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
