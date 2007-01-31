# $NetBSD: buildlink3.mk,v 1.15 2007/01/31 13:20:26 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GNOME_LIBS_BUILDLINK3_MK:=	${GNOME_LIBS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gnome-libs
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngnome-libs}
BUILDLINK_PACKAGES+=	gnome-libs
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}gnome-libs

.if !empty(GNOME_LIBS_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gnome-libs+=		gnome-libs>=1.4.2nb1
BUILDLINK_ABI_DEPENDS.gnome-libs+=	gnome-libs>=1.4.2nb6
BUILDLINK_PKGSRCDIR.gnome-libs?=	../../x11/gnome-libs
.endif	# GNOME_LIBS_BUILDLINK3_MK

.include "../../audio/esound/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../graphics/imlib/buildlink3.mk"
.include "../../net/ORBit/buildlink3.mk"
.include "../../x11/gtk/buildlink3.mk"
.include "../../x11/libXpm/buildlink3.mk"
.include "../../x11/libXt/buildlink3.mk"
.include "../../mk/bdb.buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
