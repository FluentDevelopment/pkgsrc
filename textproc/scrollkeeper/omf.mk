# $NetBSD: omf.mk,v 1.1 2003/02/18 14:39:03 jmmv Exp $
#
# This Makefile fragment is intended to be included by packages that install
# OMF files.  It takes care of registering them in scrollkeeper's global
# database.
#
# The following variables are automatically defined for free use in packages:
#    SCROLLKEEPER_DATADIR   - scrollkeeper's data directory.
#    SCROLLKEEPER_REBUILDDB - scrollkeeper-rebuilddb binary program.
#    SCROLLKEEPER_UPDATEDB  - scrollkeeper-updatedb binary program.
#

.if !defined(SCROLLKEEPER_OMF_MK)
SCROLLKEEPER_OMF_MK=	# defined

# scrollkeeper's data directory.
SCROLLKEEPER_DATADIR=	${BUILDLINK_PREFIX.scrollkeeper}/libdata/scrollkeeper

# scrollkeeper binary programs.
SCROLLKEEPER_REBUILDDB=	${BUILDLINK_PREFIX.scrollkeeper}/bin/scrollkeeper-rebuilddb
SCROLLKEEPER_UPDATEDB=	${BUILDLINK_PREFIX.scrollkeeper}/bin/scrollkeeper-updatedb

USE_PKGINSTALL=		YES
INSTALL_EXTRA_TMPL+=	${.CURDIR}/../../textproc/scrollkeeper/files/install.tmpl
DEINSTALL_EXTRA_TMPL+=	${.CURDIR}/../../textproc/scrollkeeper/files/install.tmpl

FILES_SUBST+=		SCROLLKEEPER_DATADIR="${SCROLLKEEPER_DATADIR}"
FILES_SUBST+=		SCROLLKEEPER_REBUILDDB="${SCROLLKEEPER_REBUILDDB}"
FILES_SUBST+=		SCROLLKEEPER_UPDATEDB="${SCROLLKEEPER_UPDATEDB}"

.include "../../textproc/scrollkeeper/buildlink2.mk"

.endif	# SCROLLKEEPER_OMF_MK
