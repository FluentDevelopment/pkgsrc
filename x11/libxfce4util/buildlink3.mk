# $NetBSD: buildlink3.mk,v 1.5 2004/10/03 00:18:36 tv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBXFCE4UTIL_BUILDLINK3_MK:=	${LIBXFCE4UTIL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libxfce4util
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibxfce4util}
BUILDLINK_PACKAGES+=	libxfce4util

.if !empty(LIBXFCE4UTIL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libxfce4util+=	libxfce4util>=4.0.6
BUILDLINK_RECOMMENDED.libxfce4util+=	libxfce4util>=4.0.6nb1
BUILDLINK_PKGSRCDIR.libxfce4util?=	../../x11/libxfce4util
.endif	# LIBXFCE4UTIL_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
