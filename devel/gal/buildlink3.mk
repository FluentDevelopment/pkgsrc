# $NetBSD: buildlink3.mk,v 1.3 2004/11/30 18:26:39 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GAL_BUILDLINK3_MK:=	${GAL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gal
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngal}
BUILDLINK_PACKAGES+=	gal

.if !empty(GAL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gal+=	gal>=0.22nb6
BUILDLINK_PKGSRCDIR.gal?=	../../devel/gal
.endif	# GAL_BUILDLINK3_MK

.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/bonobo/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/libglade/buildlink3.mk"
.include "../../print/gnome-print/buildlink3.mk"
.include "../../sysutils/gnome-vfs/buildlink3.mk"
#.include "../../textproc/libunicode/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
