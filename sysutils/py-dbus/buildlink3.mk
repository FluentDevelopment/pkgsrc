# $NetBSD: buildlink3.mk,v 1.3 2006/04/02 15:04:20 rxg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_DBUS_BUILDLINK3_MK:=		${PY_DBUS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	py-dbus
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npy-dbus}
BUILDLINK_PACKAGES+=	py-dbus

.if !empty(PY_DBUS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.py-dbus+=	${PYPKGPREFIX}-dbus>=0.23.4
BUILDLINK_RECOMMENDED.py-dbus?=	${PYPKGPREFIX}-dbus>=0.23.4nb2
BUILDLINK_PKGSRCDIR.py-dbus?=	../../sysutils/py-dbus
.endif	# PY_DBUS_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"
.include "../../lang/python/pyversion.mk"
.include "../../sysutils/dbus/buildlink3.mk"
.include "../../textproc/expat/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
