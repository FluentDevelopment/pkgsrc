# $NetBSD: buildlink3.mk,v 1.7 2004/03/26 02:28:02 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PY_GTK2_BUILDLINK3_MK:=	${PY_GTK2_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pygtk2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npygtk2}
BUILDLINK_PACKAGES+=	pygtk2

.if !empty(PY_GTK2_BUILDLINK3_MK:M+)
BUILDLINK_PKGBASE.pygtk2?=	${PYPKGPREFIX}-gtk2
BUILDLINK_DEPENDS.pygtk2+=	${PYPKGPREFIX}-gtk2>=2.0.0nb2
BUILDLINK_RECOMMENDED.pygtk2?=	${PYPKGPREFIX}-gtk2>=2.2.0nb1
BUILDLINK_PKGSRCDIR.pygtk2?=	../../x11/py-gtk2
.endif	# PY_GTK2_BUILDLINK3_MK

.include "../../devel/libglade2/buildlink3.mk"
.include "../../math/py-Numeric/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
