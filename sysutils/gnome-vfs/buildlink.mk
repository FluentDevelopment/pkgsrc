# $NetBSD: buildlink.mk,v 1.5 2002/03/13 17:37:43 fredb Exp $
#
# This Makefile fragment is included by packages that use gnome-vfs.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.gnome-vfs to the dependency pattern
#     for the version of gnome-vfs desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(GNOME_VFS_BUILDLINK_MK)
GNOME_VFS_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.gnome-vfs?=	gnome-vfs>=1.0.2nb1
DEPENDS+=	${BUILDLINK_DEPENDS.gnome-vfs}:../../sysutils/gnome-vfs

EVAL_PREFIX+=			BUILDLINK_PREFIX.gnome-vfs=gnome-vfs
BUILDLINK_PREFIX.gnome-vfs_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.gnome-vfs=	include/gnome-vfs-1.0/*/*
BUILDLINK_FILES.gnome-vfs+=	lib/gnome-vfs-1.0/include/*
BUILDLINK_FILES.gnome-vfs+=	lib/libgnomevfs-pthread.*
BUILDLINK_FILES.gnome-vfs+=	lib/libgnomevfs.*
BUILDLINK_FILES.gnome-vfs+=	lib/vfsConf.sh

BUILDLINK_CONFIG_WRAPPER_SED+=	\
	-e "s|-I${BUILDLINK_PREFIX.gnome-vfs}\(/include/gnome-vfs-1.0\)|-I${BUILDLINK_DIR}\1|g" \
	-e "s|-I${BUILDLINK_PREFIX.gnome-vfs}\(/lib/gnome-vfs-1.0\)|-I${BUILDLINK_DIR}\1|g"

REPLACE_BUILDLINK_SED+=	\
	-e "s|-I${BUILDLINK_DIR}\(/include/gnome-vfs-1.0\)|-I${BUILDLINK_PREFIX.gnome-vfs}\1|g" \
	-e "s|-I${BUILDLINK_DIR}\(/lib/gnome-vfs-1.0\)|-I${BUILDLINK_PREFIX.gnome-vfs}\1|g"

.include "../../devel/gettext-lib/buildlink.mk"
.include "../../devel/GConf/buildlink.mk"

BUILDLINK_TARGETS.gnome-vfs=	gnome-vfs-buildlink
BUILDLINK_TARGETS.gnome-vfs+=	gnome-vfs-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.gnome-vfs}

BUILDLINK_CONFIG.gnome-vfs=	\
		${BUILDLINK_PREFIX.gnome-vfs}/bin/gnome-vfs-config
BUILDLINK_CONFIG_WRAPPER.gnome-vfs=	\
		${BUILDLINK_DIR}/bin/gnome-vfs-config

.if defined(USE_CONFIG_WRAPPER)
GNOME_VFS_CONFIG?=	${BUILDLINK_CONFIG_WRAPPER.gnome-vfs}
CONFIGURE_ENV+=		GNOME_VFS_CONFIG="${GNOME_VFS_CONFIG}"
MAKE_ENV+=		GNOME_VFS_CONFIG="${GNOME_VFS_CONFIG}"
.endif

pre-configure: ${BUILDLINK_TARGETS.gnome-vfs}
gnome-vfs-buildlink: _BUILDLINK_USE
gnome-vfs-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.endif	# GNOME_VFS_BUILDLINK_MK
