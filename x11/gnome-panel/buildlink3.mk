# $NetBSD: buildlink3.mk,v 1.15 2006/04/06 06:22:58 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GNOME_PANEL_BUILDLINK3_MK:=	${GNOME_PANEL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gnome-panel
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngnome-panel}
BUILDLINK_PACKAGES+=	gnome-panel

.if !empty(GNOME_PANEL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gnome-panel+=		gnome-panel>=2.12.1nb3
BUILDLINK_ABI_DEPENDS.gnome-panel?=	gnome-panel>=2.12.3
BUILDLINK_PKGSRCDIR.gnome-panel?=	../../x11/gnome-panel
.endif	# GNOME_PANEL_BUILDLINK3_MK

.include "../../devel/GConf2/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/libbonobo/buildlink3.mk"
.include "../../devel/libbonoboui/buildlink3.mk"
.include "../../devel/libwnck/buildlink3.mk"
.include "../../devel/libglade2/buildlink3.mk"
.include "../../devel/libgnome/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../devel/libwnck/buildlink3.mk"
.include "../../graphics/gnome-icon-theme/buildlink3.mk"
.include "../../net/ORBit2/buildlink3.mk"
.include "../../sysutils/gnome-vfs2/buildlink3.mk"
.include "../../x11/gnome-desktop/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/startup-notification/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
