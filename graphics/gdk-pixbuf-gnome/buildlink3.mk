# $NetBSD: buildlink3.mk,v 1.5 2006/04/06 06:22:02 reed Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
GDK_PIXBUF_GNOME_BUILDLINK3_MK:=	${GDK_PIXBUF_GNOME_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gdk-pixbuf-gnome
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngdk-pixbuf-gnome}
BUILDLINK_PACKAGES+=	gdk-pixbuf-gnome

.if !empty(GDK_PIXBUF_GNOME_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gdk-pixbuf-gnome+=	gdk-pixbuf-gnome>=0.22.0nb2
BUILDLINK_ABI_DEPENDS.gdk-pixbuf-gnome?=	gdk-pixbuf-gnome>=0.22.0nb4
BUILDLINK_PKGSRCDIR.gdk-pixbuf-gnome?=	../../graphics/gdk-pixbuf-gnome
.endif	# GDK_PIXBUF_GNOME_BUILDLINK3_MK

.include "../../graphics/gdk-pixbuf/buildlink3.mk"
.include "../../x11/gnome-libs/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
