# $NetBSD: buildlink2.mk,v 1.15 2003/05/02 11:54:17 wiz Exp $
#
# This Makefile fragment is included by packages that use GConf2.
#
# This file was created automatically using createbuildlink 2.0.
#

.if !defined(GCONF2_BUILDLINK2_MK)
GCONF2_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			GConf2
BUILDLINK_DEPENDS.GConf2?=		GConf2>=2.2.0nb1
BUILDLINK_PKGSRCDIR.GConf2?=		../../devel/GConf2

EVAL_PREFIX+=	BUILDLINK_PREFIX.GConf2=GConf2
BUILDLINK_PREFIX.GConf2_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-changeset.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-client.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-engine.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-enum-types.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-error.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-listeners.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-schema.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf-value.h
BUILDLINK_FILES.GConf2+=	include/gconf/2/gconf/gconf.h
BUILDLINK_FILES.GConf2+=	lib/GConf/2/libgconfbackend-xml.*
BUILDLINK_FILES.GConf2+=	lib/libgconf-2.*

.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"
.include "../../devel/popt/buildlink2.mk"
.include "../../net/ORBit2/buildlink2.mk"
.include "../../net/linc/buildlink2.mk"
.include "../../textproc/libxml2/buildlink2.mk"

BUILDLINK_TARGETS+=	GConf2-buildlink
BUILDLINK_TARGETS+=	GConf2-buildlink-fake

_GCONF2_FAKE=		${BUILDLINK_DIR}/bin/gconftool-2

GConf2-buildlink: _BUILDLINK_USE

GConf2-buildlink-fake:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${_GCONF2_FAKE} ]; then				\
		${ECHO_BUILDLINK_MSG} "Creating ${_GCONF2_FAKE}";	\
		${MKDIR} ${_GCONF2_FAKE:H};				\
		${ECHO} "#!/bin/sh" > ${_GCONF2_FAKE};			\
		${CHMOD} +x ${_GCONF2_FAKE};				\
	fi

.endif	# GCONF2_BUILDLINK2_MK
