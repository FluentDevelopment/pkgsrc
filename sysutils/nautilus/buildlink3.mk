# $NetBSD: buildlink3.mk,v 1.17 2006/04/12 10:27:35 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
NAUTILUS_BUILDLINK3_MK:=	${NAUTILUS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	nautilus
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nnautilus}
BUILDLINK_PACKAGES+=	nautilus

.if !empty(NAUTILUS_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.nautilus+=	nautilus>=2.12.1nb1
BUILDLINK_ABI_DEPENDS.nautilus?=	nautilus>=2.12.2nb2
BUILDLINK_PKGSRCDIR.nautilus?=	../../sysutils/nautilus

PRINT_PLIST_AWK+=	/^@dirrm lib\/nautilus$$/ \
				{ print "@comment in nautilus: " $$0; next; }
PRINT_PLIST_AWK+=	/^@dirrm lib\/nautilus\/extensions-1.0$$/ \
				{ print "@comment in nautilus: " $$0; next; }
.endif	# NAUTILUS_BUILDLINK3_MK

.include "../../audio/esound/buildlink3.mk"
.include "../../devel/GConf2/buildlink3.mk"
.include "../../devel/eel2/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../devel/libbonobo/buildlink3.mk"
.include "../../devel/libbonoboui/buildlink3.mk"
.include "../../devel/libgnome/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../devel/libgsf/buildlink3.mk"
.include "../../devel/pango/buildlink3.mk"
.include "../../graphics/libart2/buildlink3.mk"
.include "../../graphics/libexif/buildlink3.mk"
.include "../../graphics/librsvg2/buildlink3.mk"
.include "../../net/ORBit2/buildlink3.mk"
.include "../../sysutils/gnome-vfs2/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/gnome-desktop/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/startup-notification/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
