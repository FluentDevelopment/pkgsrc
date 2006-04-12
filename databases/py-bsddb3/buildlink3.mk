# $NetBSD: buildlink3.mk,v 1.6 2006/04/12 10:27:05 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_BSDDB3_BUILDLINK3_MK:=	${PY_BSDDB3_BUILDLINK3_MK}+

.include "../../mk/pthread.buildlink3.mk"
.if defined(PTHREAD_TYPE) && ${PTHREAD_TYPE} == "native"
PYTHON_VERSIONS_ACCEPTED=	24 23 22
.endif
.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	py-bsddb3
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npy-bsddb3}
BUILDLINK_PACKAGES+=	py-bsddb3

.if !empty(PY_BSDDB3_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.py-bsddb3+=	${PYPKGPREFIX}-bsddb3>=4.3.3nb1
BUILDLINK_ABI_DEPENDS.py-bsddb3?=	${PYPKGPREFIX}-bsddb3>=4.3.3nb2
BUILDLINK_PKGSRCDIR.py-bsddb3?=	../../databases/py-bsddb3
.endif	# PY_BSDDB3_BUILDLINK3_MK

.include "../../databases/db4/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
