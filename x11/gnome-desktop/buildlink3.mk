# $NetBSD: buildlink3.mk,v 1.16 2006/03/30 21:47:15 jmmv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GNOME_DESKTOP_BUILDLINK3_MK:=	${GNOME_DESKTOP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gnome-desktop
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngnome-desktop}
BUILDLINK_PACKAGES+=	gnome-desktop

.if !empty(GNOME_DESKTOP_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gnome-desktop+=	gnome-desktop>=2.14.0
BUILDLINK_PKGSRCDIR.gnome-desktop?=	../../x11/gnome-desktop
.endif	# GNOME_DESKTOP_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../graphics/libgnomecanvas/buildlink3.mk"
.include "../../sysutils/gnome-vfs2/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/startup-notification/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
