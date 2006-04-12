# $NetBSD: buildlink3.mk,v 1.4 2006/04/12 10:27:05 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_METAKIT_BUILDLINK3_MK:=	${PY_METAKIT_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pymetakit
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npymetakit}
BUILDLINK_PACKAGES+=	pymetakit

.if !empty(PY_METAKIT_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pymetakit+=	${PYPKGPREFIX}-metakit-*
BUILDLINK_ABI_DEPENDS.pymetakit?=	${PYPKGPREFIX}-metakit>=2.4.9.3nb2
BUILDLINK_PKGSRCDIR.pymetakit?=	../../databases/py-metakit
.endif	# PY_METAKIT_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
