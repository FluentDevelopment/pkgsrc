# $NetBSD: buildlink3.mk,v 1.5 2004/03/26 02:27:36 wiz Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBGNOMEDB_BUILDLINK3_MK:=	${LIBGNOMEDB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libgnomedb
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibgnomedb}
BUILDLINK_PACKAGES+=	libgnomedb

.if !empty(LIBGNOMEDB_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libgnomedb+=		libgnomedb>=1.0.3
BUILDLINK_RECOMMENDED.libgnomedb?=	libgnomedb>=1.0.3nb1
BUILDLINK_PKGSRCDIR.libgnomedb?=	../../databases/libgnomedb
.endif	# LIBGNOMEDB_BUILDLINK3_MK

.include "../../databases/libgda/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/libbonoboui/buildlink3.mk"
.include "../../devel/libglade2/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/gtksourceview/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
