# $NetBSD: buildlink3.mk,v 1.7 2006/04/12 10:27:22 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PYTHON22_BUILDLINK3_MK:=	${PYTHON22_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	python22
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npython22}
BUILDLINK_PACKAGES+=	python22

.if !empty(PYTHON22_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.python22+=	python22>=2.2
BUILDLINK_PKGSRCDIR.python22?=	../../lang/python22

.if defined(BUILDLINK_DEPMETHOD.python)
BUILDLINK_DEPMETHOD.python22?=	${BUILDLINK_DEPMETHOD.python}
.endif

BUILDLINK_INCDIRS.python22+=	include/python2.2
BUILDLINK_LIBDIRS.python22+=	lib/python2.2/config
BUILDLINK_TRANSFORM+=		l:python:python2.2

.endif	# PYTHON22_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}

.include "../../mk/dlopen.buildlink3.mk"
.include "../../mk/pthread.buildlink3.mk"
