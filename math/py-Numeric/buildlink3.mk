# $NetBSD: buildlink3.mk,v 1.4 2004/03/05 19:25:37 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_NUMERIC_BUILDLINK3_MK:=	${PY_NUMERIC_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pynumeric
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npynumeric}
BUILDLINK_PACKAGES+=	pynumeric

.if !empty(PY_NUMERIC_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.pynumeric+=	${PYPKGPREFIX}-Numeric-*
BUILDLINK_PKGSRCDIR.pynumeric?=	../../math/py-Numeric
.endif	# PY_NUMERIC_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
