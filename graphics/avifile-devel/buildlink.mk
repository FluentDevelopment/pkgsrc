# $NetBSD: buildlink.mk,v 1.6 2001/08/24 03:51:06 jlam Exp $
#
# This Makefile fragment is included by packages that use avifile-devel.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.avifile to the dependency pattern
#     for the version of avifile desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(AVIFILE_BUILDLINK_MK)
AVIFILE_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.avifile?=	avifile>=0.6
DEPENDS+=	${BUILDLINK_DEPENDS.avifile}:../../graphics/avifile-devel

EVAL_PREFIX+=			BUILDLINK_PREFIX.avifile=avifile
BUILDLINK_PREFIX.avifile_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.avifile=	lib/libaviplay.*
BUILDLINK_FILES.avifile+=	lib/avifile-0.6/*
BUILDLINK_FILES.avifile+=	include/avifile/*
BUILDLINK_FILES.avifile+=	include/avifile/wine/*

BUILDLINK_TARGETS.avifile=	avifile-buildlink
BUILDLINK_TARGETS.avifile+=	avifile-buildlink-config-wrapper
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.avifile}

BUILDLINK_CONFIG.avifile=	${BUILDLINK_PREFIX.avifile}/bin/avifile-config
BUILDLINK_CONFIG_WRAPPER.avifile=${BUILDLINK_DIR}/bin/avifile-config

.if defined(USE_CONFIG_WRAPPER)
AVIFILE_CONFIG?=		${BUILDLINK_CONFIG_WRAPPER.avifile}
CONFIGURE_ENV+=			AVIFILE_CONFIG="${AVIFILE_CONFIG}"
MAKE_ENV+=			AVIFILE_CONFIG="${AVIFILE_CONFIG}"
.endif

pre-configure: ${BUILDLINK_TARGETS.avifile}
avifile-buildlink: _BUILDLINK_USE
avifile-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.endif	# AVIFILE_BUILDLINK_MK
