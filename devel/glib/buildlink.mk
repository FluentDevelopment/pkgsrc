# $NetBSD: buildlink.mk,v 1.8 2001/07/13 23:23:39 dogcow Exp $
#
# This Makefile fragment is included by packages that use glib.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.glib to the dependency pattern
#     for the version of glib desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(GLIB_BUILDLINK_MK)
GLIB_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.glib?=	glib>=1.2.8
DEPENDS+=	${BUILDLINK_DEPENDS.glib}:../../devel/glib

BUILDLINK_PREFIX.glib=	${LOCALBASE}
BUILDLINK_FILES.glib=	include/glib/*/*
BUILDLINK_FILES.glib+=	include/glib/*
BUILDLINK_FILES.glib+=	lib/glib/*/*
BUILDLINK_FILES.glib+=	lib/libglib.*
BUILDLINK_FILES.glib+=	lib/libgmodule.*
BUILDLINK_FILES.glib+=	lib/libgthread.*

.include "../../mk/bsd.prefs.mk"
.if (${OPSYS} != SunOS)
.include "../../devel/pth/buildlink.mk"
.endif

BUILDLINK_TARGETS.glib=		glib-buildlink
BUILDLINK_TARGETS.glib+=	glib-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.glib}

BUILDLINK_CONFIG.glib=		${LOCALBASE}/bin/glib-config
BUILDLINK_CONFIG_WRAPPER.glib=	${BUILDLINK_DIR}/bin/glib-config

.if defined(USE_CONFIG_WRAPPER) && defined(GNU_CONFIGURE)
GLIB_CONFIG?=		${BUILDLINK_CONFIG_WRAPPER.glib}
CONFIGURE_ENV+=		GLIB_CONFIG="${GLIB_CONFIG}"
.endif

pre-configure: ${BUILDLINK_TARGETS.glib}
glib-buildlink: _BUILDLINK_USE
glib-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.endif	# GLIB_BUILDLINK_MK
