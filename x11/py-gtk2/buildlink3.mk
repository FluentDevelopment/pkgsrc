# $NetBSD: buildlink3.mk,v 1.14 2006/04/06 06:23:02 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PY_GTK2_BUILDLINK3_MK:=	${PY_GTK2_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pygtk2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npygtk2}
BUILDLINK_PACKAGES+=	pygtk2

.if !empty(PY_GTK2_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pygtk2+=	${PYPKGPREFIX}-gtk2>=2.8.4
BUILDLINK_PKGSRCDIR.pygtk2?=	../../x11/py-gtk2
.endif	# PY_GTK2_BUILDLINK3_MK

.include "../../devel/py-gobject/buildlink3.mk"
.include "../../devel/libglade2/buildlink3.mk"
.include "../../math/py-Numeric/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
