# $NetBSD: buildlink3.mk,v 1.11 2006/04/12 10:27:44 rillig Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_NOTES_PLUGIN_BUILDLINK3_MK:=	${XFCE4_NOTES_PLUGIN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-notes-plugin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-notes-plugin}
BUILDLINK_PACKAGES+=	xfce4-notes-plugin

.if !empty(XFCE4_NOTES_PLUGIN_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.xfce4-notes-plugin+=	xfce4-notes-plugin>=0.11.1
BUILDLINK_ABI_DEPENDS.xfce4-notes-plugin?=	xfce4-notes-plugin>=0.11.1nb2
BUILDLINK_PKGSRCDIR.xfce4-notes-plugin?=	../../x11/xfce4-notes-plugin
.endif	# XFCE4_NOTES_PLUGIN_BUILDLINK3_MK

.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
