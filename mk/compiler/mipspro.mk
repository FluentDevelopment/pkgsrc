# $NetBSD: mipspro.mk,v 1.2 2004/02/01 00:59:51 jlam Exp $

.if !defined(COMPILER_MIPSPRO_MK)
COMPILER_MIPSPRO_MK=	defined

MISPROBASE?=	/usr

CC=	${MIPSPROBASE}/bin/cc
CPP=	${MIPSPROBASE}/bin/cc -E
CXX=	${MIPSPROBASE}/bin/CC

CC_VERSION!=	${CC} -V 2>&1 | ${GREP} '^cc'

.endif	# COMPILER_MIPSPRO_MK
