# $NetBSD: buildlink3.mk,v 1.4 2004/03/12 10:48:23 recht Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PY_GTK2_BUILDLINK3_MK:=	${PY_GTK2_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pygtk2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npygtk2}
BUILDLINK_PACKAGES+=	pygtk2

.if !empty(PY_GTK2_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.pygtk2+=	${PYPKGPREFIX}-gtk2>=2.0.0nb2
BUILDLINK_PKGSRCDIR.pygtk2?=	../../x11/py-gtk2

.include "../../devel/libglade2/buildlink3.mk"
.include "../../math/py-Numeric/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

.endif	# PY_GTK2_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
