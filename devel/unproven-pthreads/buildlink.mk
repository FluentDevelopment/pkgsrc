# $NetBSD: buildlink.mk,v 1.1 2002/02/08 00:13:57 jlam Exp $
#
# This Makefile fragment is included by packages that use unproven-pthreads.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.unproven-pthreads to the dependency
#     pattern for the version of unproven-pthreads desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(UNPROVEN_PTHREADS_BUILDLINK_MK)
UNPROVEN_PTHREADS_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.unproven-pthreads?=	unproven-pthreads>=0.17
DEPENDS+=	${BUILDLINK_DEPENDS.unproven-pthreads}:../../devel/unproven-pthreads

EVAL_PREFIX+=	BUILDLINK_PREFIX.unproven-pthreads=unproven-pthreads
BUILDLINK_PREFIX.unproven-pthreads_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.unproven-pthreads=		pthreads/bin/*
BUILDLINK_FILES.unproven-pthreads+=		pthreads/include/*.h
BUILDLINK_FILES.unproven-pthreads+=		pthreads/include/*/*.h
BUILDLINK_FILES.unproven-pthreads+=		pthreads/lib/*

BUILDLINK_TARGETS.unproven-pthreads=	unproven-pthreads-buildlink
BUILDLINK_TARGETS+=			${BUILDLINK_TARGETS.unproven-pthreads}

pre-configure: ${BUILDLINK_TARGETS.unproven-pthreads}
unproven-pthreads-buildlink: _BUILDLINK_USE

.endif	# UNPROVEN_PTHREADS_BUILDLINK_MK
