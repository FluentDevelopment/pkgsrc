# $NetBSD: buildlink.mk,v 1.8 2001/09/07 14:27:13 drochner Exp $
#
# This Makefile fragment is included by packages that use kdelibs2.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.kdelibs2 to the dependency pattern
#     for the version of kdelibs2 desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(KDELIBS2_BUILDLINK_MK)
KDELIBS2_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.kdelibs2?=	kdelibs>=2.1nb1
DEPENDS+=	${BUILDLINK_DEPENDS.kdelibs2}:../../x11/kdelibs2

.include "../../mk/bsd.prefs.mk"

EVAL_PREFIX+=			BUILDLINK_PREFIX.kdelibs2=kdelibs
BUILDLINK_PREFIX.kdelibs2_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.kdelibs2!=	${GREP} "^\(include\|lib\)" ${.CURDIR}/../../x11/kdelibs2/pkg/PLIST
BUILDLINK_FILES.kdelibs2+=	bin/dcopserver

.if (defined(KJS_USE_PCRE) && ${KJS_USE_PCRE} == yes)
.include "../../devel/pcre/buildlink.mk"
.endif

.include "../../archivers/bzip2/buildlink.mk"
.include "../../audio/libaudiofile/buildlink.mk"
.include "../../devel/libtool/buildlink.mk"
.include "../../graphics/tiff/buildlink.mk"
#.include "../../textproc/jade/buildlink.mk"
.include "../../x11/qt2-libs/buildlink.mk"

BUILDLINK_TARGETS.kdelibs2=	kdelibs2-buildlink
BUILDLINK_TARGETS.kdelibs2+=	kdelibs2-buildlink-config-wrapper
BUILDLINK_TARGETS.kdelibs2+=	kdelibs2-artsc-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.kdelibs2}

BUILDLINK_CONFIG.kdelibs2=		${BUILDLINK_PREFIX.kdelibs2}/bin/kde-config
BUILDLINK_CONFIG_WRAPPER.kdelibs2=	${BUILDLINK_DIR}/bin/kde-config

BUILDLINK_CONFIG.kdelibs2-artsc=	 ${BUILDLINK_PREFIX.kdelibs2}/bin/artsc-config
BUILDLINK_CONFIG_WRAPPER.kdelibs2-artsc= ${BUILDLINK_DIR}/bin/artsc-config

.if defined(USE_CONFIG_WRAPPER)
ARTSCCONFIG?=		${BUILDLINK_CONFIG_WRAPPER.kdelibs2-artsc}
KDECONFIG?=		${BUILDLINK_CONFIG_WRAPPER.kdelibs2}
CONFIGURE_ENV+=		ARTSCCONFIG="${ARTSCCONFIG}"
CONFIGURE_ENV+=		KDECONFIG="${KDECONFIG}"
MAKE_ENV+=		ARTSCCONFIG="${ARTSCCONFIG}"
MAKE_ENV+=		KDECONFIG="${KDECONFIG}"
.endif

pre-configure: ${BUILDLINK_TARGETS.kdelibs2}
kdelibs2-buildlink: _BUILDLINK_USE
kdelibs2-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE
kdelibs2-artsc-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.endif	# KDELIBS2_BUILDLINK_MK
