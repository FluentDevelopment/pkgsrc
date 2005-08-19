# $NetBSD: djbware.mk,v 1.8 2005/08/19 13:47:26 schmonz Exp $
#
# Makefile fragment for packages with djb-style build machinery
#
# Common functions provided:
# * a boilerplate RESTRICTED clause
# * typical defaults for BUILD_TARGET and INSTALL_TARGET
# * typical values for conf-* files
# * replace inline definitions of errno with "#include <errno.h>"
#
# TODO:
# * centralize handling of third-party manpages
# * centralize MASTER_SITES and SITES_foo
# * centralize compiler hack for arm{,32}
# * phase out BGWARE_INSTALLER (instead, use default INSTALL_TARGET)
# * common install script for compatibility with default conf-home pathnames
# * PKG_OPTIONS (default):
#     djbware-errno-hack (off)
#     djbware-pathname-compat (on)
#     inet6 (off)
#     pam (off)
# * set RESTRICTED automatically iff patches or other mods are applied
# * be unrestricted by default for bulk builds
#

.if !defined(DJBWARE_MK)
DJBWARE_MK=		# defined

DJB_RESTRICTED?=	YES
DJB_ERRNO_HACK?=	YES
DJB_BUILD_TARGETS?=	# empty
DJB_INSTALL_TARGETS?=	# empty
DJB_CONFIG_PREFIX?=	${PREFIX}
DJB_CONFIG_HOME?=	conf-home
DJB_CONFIG_CMDS?=	${DO_NADA}
BGWARE_INSTALLER?=	NO

.if !empty(DJB_RESTRICTED:M[yY][eE][sS])
RESTRICTED=		"modified source and binaries may not be distributed"
NO_BIN_ON_CDROM=	${RESTRICTED}
NO_BIN_ON_FTP=		${RESTRICTED}
.endif

BUILD_TARGET?=		it ${DJB_BUILD_TARGETS}
INSTALL_TARGET?=	setup check ${DJB_INSTALL_TARGETS}

.if !defined(NO_CONFIGURE) && !target(do-configure)
do-configure:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for i in conf-*; do ${CP} $${i} $${i}.orig_dist; done;		\
	[ -f ${DJB_CONFIG_HOME} ] && \
		${ECHO} ${DJB_CONFIG_PREFIX} > ${DJB_CONFIG_HOME};	\
	[ -f conf-cc ] && \
		${ECHO} ${CC:Q} ${CFLAGS:Q} > conf-cc;			\
	[ -f conf-ld ] && \
		${ECHO} ${CC:Q} ${_STRIPFLAG_CC} > conf-ld;		\
	[ -f conf-bin ] && \
		${ECHO} ${DJB_CONFIG_PREFIX}/bin > conf-bin;		\
	[ -f conf-man ] && \
		${ECHO} ${DJB_CONFIG_PREFIX}/man > conf-man;		\
	[ -f conf-qmail ] && \
		${ECHO} ${QMAILDIR} > conf-qmail;			\
	[ -f conf-bgincs ] && \
		${ECHO} ${LOCALBASE}/include/bglibs > conf-bgincs;	\
	[ -f conf-bglibs ] && \
		${ECHO} ${LOCALBASE}/lib/bglibs > conf-bglibs;		\
	${DJB_CONFIG_CMDS}
.endif

.if !empty(BGWARE_INSTALLER:M[yY][eE][sS])
. if !target(do-install)
do-install:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	./installer;							\
	./instcheck
. endif
.endif

PKG_SUPPORTED_OPTIONS+=	djbware-errno-hack
PKG_OPTIONS_LEGACY_VARS+=	DJB_ERRNO_HACK:djbware-errno-hack

.include "../../mk/bsd.prefs.mk"

.if exists(${PKGDIR}/options.mk)
. include "${PKGDIR}/options.mk"
.else
PKG_OPTIONS_VAR=	PKG_OPTIONS.${PKGBASE}
.include "../../mk/bsd.options.mk"
.endif

.if !empty(PKG_OPTIONS:Mdjbware-errno-hack)
SUBST_CLASSES+=		djbware
SUBST_STAGE.djbware=	do-configure
SUBST_FILES.djbware=	error.h
SUBST_SED.djbware=	-e 's|^extern\ int\ errno\;|\#include \<errno.h\>|'
SUBST_MESSAGE.djbware=	"Correcting definition of errno."
.endif

.endif	# DJBWARE_MK
