# $NetBSD: buildlink3.mk,v 1.6 2004/04/01 18:32:38 jmmv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBGTKHTML_BUILDLINK3_MK:=	${LIBGTKHTML_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libgtkhtml
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibgtkhtml}
BUILDLINK_PACKAGES+=	libgtkhtml

.if !empty(LIBGTKHTML_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libgtkhtml+=		libgtkhtml>=2.6.0
BUILDLINK_PKGSRCDIR.libgtkhtml?=	../../www/libgtkhtml
.endif	# LIBGTKHTML_BUILDLINK3_MK

.include "../../devel/gail/buildlink3.mk"
.include "../../sysutils/gnome-vfs2/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
