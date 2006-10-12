# $NetBSD: buildlink3.mk,v 1.17 2006/10/12 09:24:19 martti Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
XFCE4_FM_BUILDLINK3_MK:=	${XFCE4_FM_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xfce4-fm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-fm}
BUILDLINK_PACKAGES+=	xfce4-fm
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xfce4-fm

.if ${XFCE4_FM_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.xfce4-fm+=	xfce4-fm>=4.2.3nb4
BUILDLINK_PKGSRCDIR.xfce4-fm?=	../../sysutils/xfce4-fm
.endif	# XFCE4_FM_BUILDLINK3_MK

.include "../../databases/dbh/buildlink3.mk"
.include "../../graphics/hicolor-icon-theme/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/xfce4-mcs-plugins/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
