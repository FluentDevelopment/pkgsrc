# $NetBSD: buildlink3.mk,v 1.2 2004/03/18 09:12:17 jlam Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_MENUEDITOR_BUILDLINK3_MK:=	${XFCE4_MENUEDITOR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-menueditor
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-menueditor}
BUILDLINK_PACKAGES+=	xfce4-menueditor

.if !empty(XFCE4_MENUEDITOR_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.xfce4-menueditor+=	xfce4-menueditor>=1.0rc3nb2
BUILDLINK_PKGSRCDIR.xfce4-menueditor?=	../../x11/xfce4-menueditor
.endif	# XFCE4_MENUEDITOR_BUILDLINK3_MK

.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/libxfce4gui/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
