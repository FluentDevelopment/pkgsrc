# $NetBSD: buildlink3.mk,v 1.1 2004/01/25 14:05:34 recht Exp $
#
# This Makefile fragment is included by packages that use python23.
#
# This file was created automatically using createbuildlink-3.0.
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PYTHON23_BUILDLINK3_MK:=	${PYTHON23_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	python23
.endif

.if !empty(PYTHON23_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=			python23
BUILDLINK_DEPENDS.python23?=		python23>=2.3.3
BUILDLINK_PKGSRCDIR.python23?=		../../lang/python23

BUILDLINK_TRANSFORM+=		l:python:python2.3

BUILDLINK_CPPFLAGS.python23+= \
	-I${BUILDLINK_PREFIX.python23}/include/python2.3
BUILDLINK_LDFLAGS.python23+= \
	-L${BUILDLINK_PREFIX.python23}/lib/python2.3/config		\
	-Wl,-R${BUILDLINK_PREFIX.python23}/lib/python2.3/config

.endif # PYTHON23_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
