# $NetBSD: buildlink.mk,v 1.7 2001/08/17 21:14:02 jlam Exp $
#
# This Makefile fragment is included by packages that use libmikmod.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.libmikmod to the dependency pattern
#     for the version of libmikmod desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(LIBMIKMOD_BUILDLINK_MK)
LIBMIKMOD_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.libmikmod?=	libmikmod>=3.1.9
DEPENDS+=	${BUILDLINK_DEPENDS.libmikmod}:../../audio/libmikmod

EVAL_PREFIX+=			BUILDLINK_PREFIX.libmikmod=libmikmod
BUILDLINK_PREFIX.libmikmod_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libmikmod=	include/mikmod.h
BUILDLINK_FILES.libmikmod+=	lib/libmikmod.*

BUILDLINK_TARGETS.libmikmod=	libmikmod-buildlink
BUILDLINK_TARGETS.libmikmod+=	libmikmod-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.libmikmod}

BUILDLINK_CONFIG.libmikmod=	\
			${BUILDLINK_PREFIX.libmikmod}/bin/libmikmod-config
BUILDLINK_CONFIG_WRAPPER.libmikmod=	\
			${BUILDLINK_DIR}/bin/libmikmod-config

.if defined(USE_CONFIG_WRAPPER)
LIBMIKMOD_CONFIG?=	${BUILDLINK_CONFIG_WRAPPER.libmikmod}
CONFIGURE_ENV+=		LIBMIKMOD_CONFIG="${LIBMIKMOD_CONFIG}"
MAKE_ENV+=		LIBMIKMOD_CONFIG="${LIBMIKMOD_CONFIG}"
.endif

pre-configure: ${BUILDLINK_TARGETS.libmikmod}
libmikmod-buildlink: _BUILDLINK_USE
libmikmod-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.endif	# LIBMIKMOD_BUILDLINK_MK
