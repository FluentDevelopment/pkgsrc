# $NetBSD: buildlink3.mk,v 1.12 2006/04/06 06:22:46 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
XFCE4_FM_BUILDLINK3_MK:=	${XFCE4_FM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-fm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-fm}
BUILDLINK_PACKAGES+=	xfce4-fm

.if !empty(XFCE4_FM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.xfce4-fm+=	xfce4-fm>=4.2.3
BUILDLINK_ABI_DEPENDS.xfce4-fm?=	xfce4-fm>=4.2.3nb2
BUILDLINK_PKGSRCDIR.xfce4-fm?=	../../sysutils/xfce4-fm
.endif	# XFCE4_FM_BUILDLINK3_MK

.include "../../databases/dbh/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/xfce4-mcs-plugins/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
