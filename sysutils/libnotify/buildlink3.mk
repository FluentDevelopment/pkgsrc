# $NetBSD: buildlink3.mk,v 1.3 2006/04/17 13:46:10 wiz Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBNOTIFY_BUILDLINK3_MK:=	${LIBNOTIFY_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libnotify
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibnotify}
BUILDLINK_PACKAGES+=	libnotify

.if !empty(LIBNOTIFY_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libnotify+=	libnotify>=0.3.2
BUILDLINK_ABI_DEPENDS.libnotify?=	libnotify>=0.3.2nb1
BUILDLINK_PKGSRCDIR.libnotify?=	../../sysutils/libnotify
.endif	# LIBNOTIFY_BUILDLINK3_MK

#.include "../../devel/glib2/buildlink3.mk"
.include "../../sysutils/dbus/buildlink3.mk"
.include "../../sysutils/dbus-glib/buildlink3.mk"
#.include "../../x11/gtk2/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
