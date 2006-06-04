#	$NetBSD: bsd.pkg.mk,v 1.1828 2006/06/04 00:39:05 jlam Exp $
#
# This file is in the public domain.
#
# This file is derived from bsd.port.mk - 940820 Jordan K. Hubbard.
#
# Please see the pkgsrc/doc/guide manual for details on the
# variables used in this make file template.
#
# Default sequence for "all" is:  fetch checksum extract patch configure build
#
# Please read the comments in the targets section below, you
# should be able to use the pre-* or post-* targets/scripts
# (which are available for every stage except checksum) or
# override the do-* targets to do pretty much anything you want.

############################################################################
# Include any preferences, if not already included, and common definitions
############################################################################

.include "../../mk/bsd.prefs.mk"
.include "../../mk/bsd.hacks.mk"

# This has to come first to avoid showing all BUILD_DEFS added by this
# Makefile, which are usually not customizable.
.PHONY: build-defs-message
pre-depends-hook: build-defs-message
.if empty(PKGSRC_SHOW_BUILD_DEFS:M[yY][eE][sS])
build-defs-message:
.elif !target(build-defs-message)
build-defs-message: ${WRKDIR}
.  if defined(BUILD_DEFS) && !empty(BUILD_DEFS)
.    if !exists(${WRKDIR}/.bdm_done)
	@${ECHO} "=========================================================================="
	@${ECHO} "The following variables will affect the build process of this package,"
	@${ECHO} "${PKGNAME}.  Their current value is shown below:"
	@${ECHO} ""
.      for var in ${BUILD_DEFS:O}
.        if !defined(${var})
	@${ECHO} "        * ${var} (not defined)"
.        elif defined(${var}) && empty(${var})
	@${ECHO} "        * ${var} (defined)"
.        else
	@${ECHO} "        * ${var} = ${${var}}"
.        endif
.      endfor
	@${ECHO} ""
	@${ECHO} "You may want to abort the process now with CTRL-C and change their value"
	@${ECHO} "before continuing.  Be sure to run \`${MAKE} clean' after"
	@${ECHO} "the changes."
	@${ECHO} "=========================================================================="
	@${TOUCH} ${WRKDIR}/.bdm_done
.    endif
.  endif
.endif

############################################################################
# Transform package Makefile variables and set defaults
############################################################################

MKCRYPTO?=		YES	# build crypto packages by default
NOCLEAN?=		NO	# don't clean up after update
REINSTALL?=		NO	# reinstall upon update
CREATE_WRKDIR_SYMLINK?=	yes	# create a symlink to WRKOBJDIR

##### Variant spellings

.if defined(LICENCE) && !defined(LICENSE)
LICENSE=		${LICENCE}
.endif
.if defined(ACCEPTABLE_LICENCES) && !defined(ACCEPTABLE_LICENSES)
ACCEPTABLE_LICENSES=	${ACCEPTABLE_LICENCES}
.endif

##### PKGBASE, PKGNAME[_NOREV], PKGVERSION

PKGBASE?=		${PKGNAME:C/-[^-]*$//}
PKGVERSION?=		${PKGNAME:C/^.*-//}
.if defined(PKGREVISION) && !empty(PKGREVISION) && (${PKGREVISION} != "0")
.  if defined(PKGNAME)
PKGNAME_NOREV:=		${PKGNAME}
PKGNAME:=		${PKGNAME}nb${PKGREVISION}
.  else
PKGNAME?=		${DISTNAME}nb${PKGREVISION}
PKGNAME_NOREV=		${DISTNAME}
.  endif
.else
PKGNAME?=		${DISTNAME}
PKGNAME_NOREV=		${PKGNAME}
.endif

##### Others

_DISTDIR?=		${DISTDIR}/${DIST_SUBDIR}
BUILD_DEPENDS?=		# empty
BUILD_TARGET?=		all
COMMENT?=		(no description)
CONFIGURE_DIRS?=	${WRKSRC}
CONFIGURE_SCRIPT?=	./configure
DEPENDS?=		# empty
DESCR_SRC?=		${PKGDIR}/DESCR
DIGEST_ALGORITHMS?=	SHA1 RMD160
DISTFILES?=		${DISTNAME}${EXTRACT_SUFX}
DISTINFO_FILE?=		${PKGDIR}/distinfo
INTERACTIVE_STAGE?=	none
MAINTAINER?=		pkgsrc-users@NetBSD.org
MAKE_FLAGS?=		# empty
MAKEFILE?=		Makefile
PATCH_DIGEST_ALGORITHM?=SHA1
PKGWILDCARD?=		${PKGBASE}-[0-9]*
SVR4_PKGNAME?=		${PKGNAME}
USE_DIGEST?=		YES
WRKSRC?=		${WRKDIR}/${DISTNAME}

.if (defined(INSTALL_UNSTRIPPED) && !empty(INSTALL_UNSTRIPPED:M[yY][eE][sS])) || defined(DEBUG_FLAGS)
_INSTALL_UNSTRIPPED=	# set (flag used by platform/*.mk)
.endif

##### Non-overridable constants

# Latest versions of tools required for correct pkgsrc operation.
DIGEST_REQD=		20010302
PKGTOOLS_REQD=		${_OPSYS_PKGTOOLS_REQD:U20051103}

##### Transform USE_* into dependencies

.include "../../mk/bsd.pkg.use.mk"

############################################################################
# Sanity checks
############################################################################

# Fail-safe in the case of circular dependencies
.if defined(_PKGSRC_DEPS) && defined(PKGNAME) && !empty(_PKGSRC_DEPS:M${PKGNAME})
PKG_FAIL_REASON+=	"Circular dependency detected"
.endif

# PKG_INSTALLATION_TYPE can only be one of two values: "pkgviews" or
# "overwrite".
.if (${PKG_INSTALLATION_TYPE} != "pkgviews") && \
    (${PKG_INSTALLATION_TYPE} != "overwrite")
PKG_FAIL_REASON+=	"PKG_INSTALLATION_TYPE must be \`\`pkgviews'' or \`\`overwrite''."
.endif

.if empty(PKG_INSTALLATION_TYPES:M${PKG_INSTALLATION_TYPE})
PKG_FAIL_REASON+=	"This package doesn't support PKG_INSTALLATION_TYPE=${PKG_INSTALLATION_TYPE}."
.endif

# Check that we are using up-to-date pkg_* tools with this file.
.if !defined(NO_PKGTOOLS_REQD_CHECK)
.  if ${PKGTOOLS_VERSION} < ${PKGTOOLS_REQD}
PKG_FAIL_REASON+='Error: The package tools installed on this system are out of date.'
PKG_FAIL_REASON+='The installed package tools are dated ${PKGTOOLS_VERSION:C|(....)(..)(..)|\1/\2/\3|} and you must update'
PKG_FAIL_REASON+='them to at least ${PKGTOOLS_REQD:C|(....)(..)(..)|\1/\2/\3|} using the following command:'
PKG_FAIL_REASON+=''
PKG_FAIL_REASON+='	(cd ${PKGSRCDIR}/pkgtools/pkg_install && ${MAKE} clean && ${MAKE} update)'
.  endif
.endif # !NO_PKGTOOLS_REQD_CHECK

.if defined(ALL_TARGET)
PKG_FAIL_REASON+='ALL_TARGET is deprecated and must be replaced with BUILD_TARGET.'
.endif

.if defined(NO_WRKSUBDIR)
PKG_FAIL_REASON+='NO_WRKSUBDIR has been deprecated - please replace it with an explicit'
PKG_FAIL_REASON+='assignment of WRKSRC= $${WRKDIR}'
.endif # NO_WRKSUBDIR

# We need to make sure the buildlink-x11 package is not installed since it
# breaks builds that use imake.
.if defined(USE_IMAKE)
.  if exists(${LOCALBASE}/lib/X11/config/buildlinkX11.def) || \
      exists(${X11BASE}/lib/X11/config/buildlinkX11.def)
PKG_FAIL_REASON+= "${PKGNAME} uses imake, but the buildlink-x11 package was found." \
	 "    Please deinstall it (pkg_delete buildlink-x11)."
.  endif
.endif	# USE_IMAKE

.if !defined(CATEGORIES) || !defined(DISTNAME)
PKG_FAIL_REASON+='CATEGORIES and DISTNAME are mandatory.'
.endif

.if defined(LIB_DEPENDS)
PKG_FAIL_REASON+='LIB_DEPENDS is deprecated and must be replaced with DEPENDS.'
.endif

.if defined(PKG_PATH)
PKG_FAIL_REASON+='Please unset PKG_PATH before doing pkgsrc work!'
.endif

.if defined(MASTER_SITE_SUBDIR)
PKG_FAIL_REASON+='MASTER_SITE_SUBDIR is deprecated and must be replaced with MASTER_SITES.'
.endif

.if defined(PATCH_SITE_SUBDIR)
PKG_FAIL_REASON+='PATCH_SITE_SUBDIR is deprecated and must be replaced with PATCH_SITES.'
.endif

.if defined(ONLY_FOR_ARCHS) || defined(NOT_FOR_ARCHS) \
	|| defined(ONLY_FOR_OPSYS) || defined(NOT_FOR_OPSYS)
PKG_FAIL_REASON+='ONLY/NOT_FOR_ARCHS/OPSYS are deprecated and must be replaced with ONLY/NOT_FOR_PLATFORM.'
.endif

# Allow variables to be set on a per-OS basis
OPSYSVARS+=	CFLAGS CXXFLAGS CPPFLAGS LDFLAGS LIBS
.for _var_ in ${OPSYSVARS:O}
.  if defined(${_var_}.${OPSYS})
${_var_}+=	${${_var_}.${OPSYS}}
.  elif defined(${_var_}.*)
${_var_}+=	${${_var_}.*}
.  endif
.endfor

CPPFLAGS+=	${CPP_PRECOMP_FLAGS}

ALL_ENV+=	CC=${CC:Q}
ALL_ENV+=	CFLAGS=${CFLAGS:M*:Q}
ALL_ENV+=	CPPFLAGS=${CPPFLAGS:M*:Q}
ALL_ENV+=	CXX=${CXX:M*:Q}
ALL_ENV+=	CXXFLAGS=${CXXFLAGS:M*:Q}
ALL_ENV+=	COMPILER_RPATH_FLAG=${COMPILER_RPATH_FLAG:Q}
ALL_ENV+=	F77=${FC:Q}
ALL_ENV+=	FC=${FC:Q}
ALL_ENV+=	FFLAGS=${FFLAGS:M*:Q}
ALL_ENV+=	LANG=C
ALL_ENV+=	LC_COLLATE=C
ALL_ENV+=	LC_CTYPE=C
ALL_ENV+=	LC_MESSAGES=C
ALL_ENV+=	LC_MONETARY=C
ALL_ENV+=	LC_NUMERIC=C
ALL_ENV+=	LC_TIME=C
ALL_ENV+=	LDFLAGS=${LDFLAGS:M*:Q}
ALL_ENV+=	LINKER_RPATH_FLAG=${LINKER_RPATH_FLAG:Q}
ALL_ENV+=	PATH=${PATH:Q}:${LOCALBASE}/bin:${X11BASE}/bin
ALL_ENV+=	PREFIX=${PREFIX}

MAKE_ENV+=	${ALL_ENV}
MAKE_ENV+=	${NO_EXPORT_CPP:D:UCPP=${CPP:Q}}
MAKE_ENV+=	LINK_ALL_LIBGCC_HACK=${LINK_ALL_LIBGCC_HACK:Q}
MAKE_ENV+=	LOCALBASE=${LOCALBASE:Q}
MAKE_ENV+=	NO_WHOLE_ARCHIVE_FLAG=${NO_WHOLE_ARCHIVE_FLAG:Q}
MAKE_ENV+=	WHOLE_ARCHIVE_FLAG=${WHOLE_ARCHIVE_FLAG:Q}
MAKE_ENV+=	X11BASE=${X11BASE:Q}
MAKE_ENV+=	X11PREFIX=${X11PREFIX:Q}
MAKE_ENV+=	PKGMANDIR=${PKGMANDIR:Q}

# Constants to provide a consistent environment for packages using
# BSD-style Makefiles.
MAKE_ENV+=	MAKECONF=${PKGMAKECONF:U/dev/null}
MAKE_ENV+=	OBJECT_FMT=${OBJECT_FMT:Q}
MAKE_ENV+=	${USETOOLS:DUSETOOLS=${USETOOLS:Q}}

SCRIPTS_ENV+=	${ALL_ENV}
SCRIPTS_ENV+=	_PKGSRCDIR=${_PKGSRCDIR}
SCRIPTS_ENV+=	${BATCH:DBATCH=yes}
SCRIPTS_ENV+=	CURDIR=${.CURDIR}
SCRIPTS_ENV+=	DEPENDS=${DEPENDS:Q}
SCRIPTS_ENV+=	DISTDIR=${DISTDIR}
SCRIPTS_ENV+=	FILESDIR=${FILESDIR}
SCRIPTS_ENV+=	LOCALBASE=${LOCALBASE}
SCRIPTS_ENV+=	PATCHDIR=${PATCHDIR}
SCRIPTS_ENV+=	PKGSRCDIR=${PKGSRCDIR}
SCRIPTS_ENV+=	SCRIPTDIR=${SCRIPTDIR}
SCRIPTS_ENV+=	VIEWBASE=${VIEWBASE}
SCRIPTS_ENV+=	WRKDIR=${WRKDIR}
SCRIPTS_ENV+=	WRKSRC=${WRKSRC}
SCRIPTS_ENV+=	X11BASE=${X11BASE}

CONFIGURE_ENV+=	${ALL_ENV}

# Store the result in the +BUILD_INFO file so we can query for the build
# options using "pkg_info -Q PKG_OPTIONS <pkg>".
#
.if defined(PKG_SUPPORTED_OPTIONS) && defined(PKG_OPTIONS)
BUILD_DEFS+=            PKG_OPTIONS
.endif

.if empty(DEPOT_SUBDIR)
PKG_FAIL_REASON+=	"DEPOT_SUBDIR may not be empty."
.endif

# Automatically increase process limit where necessary for building.
_ULIMIT_CMD=		${UNLIMIT_RESOURCES:@_lim_@${ULIMIT_CMD_${_lim_}};@}

# If GNU_CONFIGURE is defined, then pass LIBS to the GNU configure script.
# also pass in a CONFIG_SHELL to avoid picking up bash
.if defined(GNU_CONFIGURE)
CONFIG_SHELL?=		${SH}
CONFIGURE_ENV+=		CONFIG_SHELL=${CONFIG_SHELL:Q}
CONFIGURE_ENV+=		LIBS=${LIBS:M*:Q}
CONFIGURE_ENV+=		install_sh=${INSTALL:Q}
.  if (defined(USE_LIBTOOL) || !empty(PKGDIR:M*/libtool-base)) && defined(_OPSYS_MAX_CMDLEN_CMD)
CONFIGURE_ENV+=		lt_cv_sys_max_cmd_len=${_OPSYS_MAX_CMDLEN_CMD:sh}
.  endif
.endif

_TOOLS_COOKIE=		${WRKDIR}/.tools_done
_WRAPPER_COOKIE=	${WRKDIR}/.wrapper_done
_CONFIGURE_COOKIE=	${WRKDIR}/.configure_done
_BUILD_COOKIE=		${WRKDIR}/.build_done
_TEST_COOKIE=		${WRKDIR}/.test_done
_INTERACTIVE_COOKIE=	.interactive_stage
_NULL_COOKIE=		${WRKDIR}/.null

# Miscellaneous overridable commands:
SHCOMMENT?=		${ECHO_MSG} >/dev/null '***'

LIBABISUFFIX?=

TOUCH_FLAGS?=		-f

# Debugging levels for this file, dependent on PKG_DEBUG_LEVEL definition
# 0 == normal, default, quiet operation
# 1 == all shell commands echoed before invocation
# 2 == shell "set -x" operation
PKG_DEBUG_LEVEL?=	0
_PKG_SILENT=		@
_PKG_DEBUG=		# empty
_PKG_DEBUG_SCRIPT=	# empty

.if ${PKG_DEBUG_LEVEL} > 0
_PKG_SILENT=		# empty
.endif

.if ${PKG_DEBUG_LEVEL} > 1
_PKG_DEBUG=		set -x;
_PKG_DEBUG_SCRIPT=	${SH} -x
.endif

# A few aliases for *-install targets
INSTALL=		${TOOLS_INSTALL}	# XXX override sys.mk
INSTALL_PROGRAM?= 	\
	${INSTALL} ${COPY} ${_STRIPFLAG_INSTALL} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_GAME?=		\
	${INSTALL} ${COPY} ${_STRIPFLAG_INSTALL} -o ${GAMEOWN} -g ${GAMEGRP} -m ${GAMEMODE}
INSTALL_SCRIPT?= 	\
	${INSTALL} ${COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_LIB?= 		\
	${INSTALL} ${COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_DATA?= 		\
	${INSTALL} ${COPY} -o ${SHAREOWN} -g ${SHAREGRP} -m ${SHAREMODE}
INSTALL_GAME_DATA?= 	\
	${INSTALL} ${COPY} -o ${GAMEOWN} -g ${GAMEGRP} -m ${GAMEDATAMODE}
INSTALL_MAN?= 		\
	${INSTALL} ${COPY} -o ${MANOWN} -g ${MANGRP} -m ${MANMODE}
INSTALL_PROGRAM_DIR?= 	\
	${INSTALL} -d -o ${BINOWN} -g ${BINGRP} -m ${PKGDIRMODE}
INSTALL_GAME_DIR?=		\
	${INSTALL} -d -o ${GAMEOWN} -g ${GAMEGRP} -m ${GAMEDIRMODE}
INSTALL_SCRIPT_DIR?= 	\
	${INSTALL_PROGRAM_DIR}
INSTALL_LIB_DIR?= 	\
	${INSTALL_PROGRAM_DIR}
INSTALL_DATA_DIR?= 	\
	${INSTALL} -d -o ${SHAREOWN} -g ${SHAREGRP} -m ${PKGDIRMODE}
INSTALL_MAN_DIR?= 	\
	${INSTALL} -d -o ${MANOWN} -g ${MANGRP} -m ${PKGDIRMODE}

INSTALL_MACROS=	BSD_INSTALL_PROGRAM=${INSTALL_PROGRAM:Q}		\
		BSD_INSTALL_SCRIPT=${INSTALL_SCRIPT:Q}			\
		BSD_INSTALL_LIB=${INSTALL_LIB:Q}			\
		BSD_INSTALL_DATA=${INSTALL_DATA:Q}			\
		BSD_INSTALL_MAN=${INSTALL_MAN:Q}			\
		BSD_INSTALL=${INSTALL:Q}				\
		BSD_INSTALL_PROGRAM_DIR=${INSTALL_PROGRAM_DIR:Q}	\
		BSD_INSTALL_SCRIPT_DIR=${INSTALL_SCRIPT_DIR:Q}		\
		BSD_INSTALL_LIB_DIR=${INSTALL_LIB_DIR:Q}		\
		BSD_INSTALL_DATA_DIR=${INSTALL_DATA_DIR:Q}		\
		BSD_INSTALL_MAN_DIR=${INSTALL_MAN_DIR:Q}		\
		BSD_INSTALL_GAME=${INSTALL_GAME:Q}			\
		BSD_INSTALL_GAME_DATA=${INSTALL_GAME_DATA:Q}		\
		BSD_INSTALL_GAME_DIR=${INSTALL_GAME_DIR:Q}
MAKE_ENV+=	${INSTALL_MACROS}
SCRIPTS_ENV+=	${INSTALL_MACROS}

# If pkgsrc is supposed to ensure that tests are run before installation
# of the package, then the build targets should be "build test", otherwise
# just "build" suffices.
#
.if !empty(PKGSRC_RUN_TEST:M[yY][eE][sS])
_PKGSRC_BUILD_TARGETS=	build test
.else
_PKGSRC_BUILD_TARGETS=	build
.endif

# The user can override the NO_PACKAGE by specifying this from
# the make command line
.if defined(FORCE_PACKAGE)
.  undef NO_PACKAGE
.endif

# Handle alternatives
#
.include "../../mk/alternatives.mk"

# INSTALL/DEINSTALL script framework
.include "../../mk/pkginstall/bsd.pkginstall.mk"

.PHONY: uptodate-digest
uptodate-digest:
.if !empty(USE_DIGEST:M[yY][eE][sS])
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${DISTINFO_FILE} -a \( ! -f ${DIGEST} -o ${DIGEST_VERSION} -lt ${DIGEST_REQD} \) ]; then \
		{ cd ${PKGSRCDIR}/pkgtools/digest;			\
		${MAKE} clean;						\
		if [ -f ${DIGEST} ]; then				\
			${MAKE} ${MAKEFLAGS} deinstall;			\
		fi;							\
		${MAKE} ${MAKEFLAGS} ${_PKGSRC_BUILD_TARGETS};		\
		if [ -f ${DIGEST} ]; then				\
			${MAKE} ${MAKEFLAGS} deinstall;			\
		fi;							\
		${MAKE} ${MAKEFLAGS} ${DEPENDS_TARGET};			\
		${MAKE} ${MAKEFLAGS} clean; } 				\
	fi
.else
	@${DO_NADA}
.endif

# Define SMART_MESSAGES in /etc/mk.conf for messages giving the tree
# of dependencies for building, and the current target.
_PKGSRC_IN?=		===${SMART_MESSAGES:D> ${.TARGET} [${PKGNAME}${_PKGSRC_DEPS}] ===}

# Used to print all the '===>' style prompts - override this to turn them off.
ECHO_MSG?=		${ECHO}
PHASE_MSG?=		${ECHO_MSG} ${_PKGSRC_IN:Q}\>
STEP_MSG?=		${ECHO_MSG} "=>"
WARNING_MSG?=		${ECHO_MSG} 1>&2 "WARNING:"
ERROR_MSG?=		${ECHO_MSG} 1>&2 "ERROR:"

# How to do nothing.  Override if you, for some strange reason, would rather
# do something.
DO_NADA?=		${TRUE}

# If this host is behind a filtering firewall, use passive ftp(1)
FETCH_BEFORE_ARGS+=	${PASSIVE_FETCH:D-p}

# Include popular master sites
.include "../../mk/bsd.sites.mk"

_MASTER_SITE_BACKUP=	${MASTER_SITE_BACKUP:=${DIST_SUBDIR}${DIST_SUBDIR:D/}}
_MASTER_SITE_OVERRIDE=	${MASTER_SITE_OVERRIDE:=${DIST_SUBDIR}${DIST_SUBDIR:D/}}

# Where to put distfiles that don't have any other master site
MASTER_SITE_LOCAL?=	${MASTER_SITE_BACKUP:=LOCAL_PORTS/}

ALLFILES?=	${DISTFILES} ${PATCHFILES}
CKSUMFILES?=	${ALLFILES}
.for __tmp__ in ${IGNOREFILES}
CKSUMFILES:=	${CKSUMFILES:N${__tmp__}}
.endfor

# List of all files, with ${DIST_SUBDIR} in front.  Used for fetch and checksum.
.if defined(DIST_SUBDIR)
_CKSUMFILES?=	${CKSUMFILES:S/^/${DIST_SUBDIR}\//}
_DISTFILES?=	${DISTFILES:S/^/${DIST_SUBDIR}\//}
_IGNOREFILES?=	${IGNOREFILES:S/^/${DIST_SUBDIR}\//}
_PATCHFILES?=	${PATCHFILES:S/^/${DIST_SUBDIR}\//}
.else
_CKSUMFILES?=	${CKSUMFILES}
_DISTFILES?=	${DISTFILES}
_IGNOREFILES?=	${IGNOREFILES}
_PATCHFILES?=	${PATCHFILES}
.endif
_ALLFILES?=	${_DISTFILES} ${_PATCHFILES}

BUILD_DEFS+=	_DISTFILES _PATCHFILES

.if defined(GNU_CONFIGURE)
HAS_CONFIGURE=		yes

GNU_CONFIGURE_PREFIX?=	${PREFIX}
CONFIGURE_ARGS+=	--prefix=${GNU_CONFIGURE_PREFIX:Q}

USE_GNU_CONFIGURE_HOST?=	yes
.  if !empty(USE_GNU_CONFIGURE_HOST:M[yY][eE][sS])
CONFIGURE_ARGS+=	--host=${MACHINE_GNU_PLATFORM:Q}
.  endif

# Support for alternative info directories in packages is very sketchy.
# For now, if we configure a package to install entirely into a
# subdirectory of ${PREFIX}, then root the info directory directly under
# that subdirectory.
#
CONFIGURE_HAS_INFODIR?=	yes
.if ${GNU_CONFIGURE_PREFIX} == ${PREFIX}
GNU_CONFIGURE_INFODIR?=	${GNU_CONFIGURE_PREFIX}/${PKGINFODIR}
.else
GNU_CONFIGURE_INFODIR?=	${GNU_CONFIGURE_PREFIX}/info
.endif
.  if defined(INFO_FILES) && !empty(CONFIGURE_HAS_INFODIR:M[yY][eE][sS])
CONFIGURE_ARGS+=	--infodir=${GNU_CONFIGURE_INFODIR:Q}
.  endif

CONFIGURE_HAS_MANDIR?=	yes
GNU_CONFIGURE_MANDIR?=	${GNU_CONFIGURE_PREFIX}/${PKGMANDIR}
.  if !empty(CONFIGURE_HAS_MANDIR:M[yY][eE][sS])
CONFIGURE_ARGS+=	--mandir=${GNU_CONFIGURE_MANDIR:Q}
.  endif
#
# By default, override config.guess and config.sub for GNU configure
# packages. pkgsrc's updated versions of these scripts allows GNU
# configure to recognise NetBSD ports such as shark.
#
CONFIG_GUESS_OVERRIDE?=		\
	config.guess */config.guess */*/config.guess
CONFIG_SUB_OVERRIDE?=		\
	config.sub */config.sub */*/config.sub
CONFIG_RPATH_OVERRIDE?=		# set by platform file as needed
#
# By default, override GNU configure scripts so that the generated
# config.status scripts never do anything on "recheck".
#
CONFIGURE_SCRIPTS_OVERRIDE?=	\
	configure */configure */*/configure
.endif

#
# Config file related settings - see doc/pkgsrc.txt
#
PKG_SYSCONFVAR?=	${PKGBASE}
PKG_SYSCONFSUBDIR?=	# empty
.if ${PKG_INSTALLATION_TYPE} == "overwrite"
PKG_SYSCONFDEPOTBASE=	# empty
PKG_SYSCONFBASEDIR=	${PKG_SYSCONFBASE}
.else
.  if !empty(PKG_SYSCONFBASE:M${PREFIX}) || \
      !empty(PKG_SYSCONFBASE:M${PREFIX}/*)
PKG_SYSCONFDEPOTBASE=	# empty
PKG_SYSCONFBASEDIR=	${PKG_SYSCONFBASE}
.  else
PKG_SYSCONFDEPOTBASE=	${PKG_SYSCONFBASE}/${DEPOT_SUBDIR}
PKG_SYSCONFBASEDIR=	${PKG_SYSCONFDEPOTBASE}/${PKGNAME}
.  endif
.endif
.if empty(PKG_SYSCONFSUBDIR)
DFLT_PKG_SYSCONFDIR:=	${PKG_SYSCONFBASEDIR}
.else
DFLT_PKG_SYSCONFDIR:=	${PKG_SYSCONFBASEDIR}/${PKG_SYSCONFSUBDIR}
.endif
PKG_SYSCONFDIR=		${DFLT_PKG_SYSCONFDIR}
.if defined(PKG_SYSCONFDIR.${PKG_SYSCONFVAR})
PKG_SYSCONFDIR=		${PKG_SYSCONFDIR.${PKG_SYSCONFVAR}}
PKG_SYSCONFBASEDIR=	${PKG_SYSCONFDIR.${PKG_SYSCONFVAR}}
PKG_SYSCONFDEPOTBASE=	# empty
.endif
PKG_SYSCONFDIR_PERMS?=	${ROOT_USER} ${ROOT_GROUP} 755

ALL_ENV+=		PKG_SYSCONFDIR=${PKG_SYSCONFDIR:Q}
BUILD_DEFS+=		PKG_SYSCONFBASEDIR PKG_SYSCONFDIR

# These are all of the tools use by pkgsrc Makefiles.  This should
# eventually be split up into lists of tools required by different
# phases of a pkgsrc build.
#
USE_TOOLS+=								\
	[ awk basename cat chgrp chmod chown cmp cp cut dirname echo	\
	egrep env false file find grep head hostname id install ln ls	\
	mkdir mv pax pwd rm rmdir sed sh sort tail test touch tr true	\
	wc xargs

# bsd.wrapper.mk
USE_TOOLS+=	expr

# bsd.bulk-pkg.mk uses certain tools
.if defined(BATCH)
USE_TOOLS+=	tee tsort
.endif

# We need shlock and sleep if we're using locking to synchronize multiple
# builds over the same pkgsrc tree.
#
.if ${PKGSRC_LOCKTYPE} != "none"
USE_TOOLS+=	shlock sleep
.endif

# Extract
.include "../../mk/bsd.pkg.extract.mk"

# Patch
.include "../../mk/bsd.pkg.patch.mk"

# Tools
.include "../../mk/tools/bsd.tools.mk"

# Unprivileged builds
.include "../../mk/unprivileged.mk"

# If NO_BUILD is defined, default to not needing a compiler.
.if defined(NO_BUILD)
USE_LANGUAGES?=		# empty
.endif

# Get the proper dependencies and set the PATH to use the compiler
# named in PKGSRC_COMPILER.
#
.include "../../mk/compiler.mk"

.include "../../mk/wrapper/bsd.wrapper.mk"

.if defined(ABI_DEPENDS) || defined(BUILD_ABI_DEPENDS)
.  if !empty(USE_ABI_DEPENDS:M[yY][eE][sS])
DEPENDS+=		${ABI_DEPENDS}
BUILD_DEPENDS+=		${BUILD_ABI_DEPENDS}
.  else
BUILD_DEFS+=		USE_ABI_DEPENDS
.  endif
.endif

# Find out the PREFIX of dependencies where the PREFIX is needed at build time.
.if defined(EVAL_PREFIX)
FIND_PREFIX:=	${EVAL_PREFIX}
.  include "../../mk/find-prefix.mk"
.endif

.if !defined(_PATH_ORIG)
_PATH_ORIG:=		${PATH}
MAKEFLAGS+=		_PATH_ORIG=${_PATH_ORIG:Q}
.endif

.if !empty(PREPEND_PATH:M*)
# This is very Special.  Because PREPEND_PATH is set with += in reverse order,
# this command reverses the order again (since bootstrap bmake doesn't
# yet support the :[-1..1] construct).
_PATH_CMD= \
	path=${_PATH_ORIG:Q};						\
	for i in ${PREPEND_PATH}; do path="$$i:$$path"; done;		\
	${ECHO} "$$path"
PATH=	${_PATH_CMD:sh} # DOES NOT use :=, to defer evaluation
.endif

# Add these bits to the environment use when invoking the sub-make
# processes for build-related phases.
#
BUILD_ENV+=		PATH=${PATH:Q}

.MAIN: all

################################################################
# Many ways to disable a package.
#
# Ignore packages that can't be resold if building for a CDROM.
#
# Don't build a package if it's restricted and we don't want to
# get into that.
#
# Don't build any package that utilizes strong cryptography, for
# when the law of the land forbids it.
#
# Don't attempt to build packages against X if we don't have X.
#
# Don't build a package if it's broken.
################################################################

.if !defined(NO_SKIP)
.  if (defined(NO_BIN_ON_CDROM) && defined(FOR_CDROM))
PKG_FAIL_REASON+= "${PKGNAME} may not be placed in binary form on a CDROM:" \
         "    "${NO_BIN_ON_CDROM:Q}
.  endif
.  if (defined(NO_SRC_ON_CDROM) && defined(FOR_CDROM))
PKG_FAIL_REASON+= "${PKGNAME} may not be placed in source form on a CDROM:" \
         "    "${NO_SRC_ON_CDROM:Q}
.  endif
.  if (defined(RESTRICTED) && defined(NO_RESTRICTED))
PKG_FAIL_REASON+= "${PKGNAME} is restricted:" \
	 "    "${RESTRICTED:Q}
.  endif
.  if !(${MKCRYPTO} == "YES" || ${MKCRYPTO} == yes)
.    if defined(CRYPTO)
PKG_FAIL_REASON+= "${PKGNAME} may not be built, because it utilizes strong cryptography"
.    endif
.  endif
.  if defined(USE_X11) && !exists(${X11BASE})
.    if ${X11_TYPE} == "native"
PKG_FAIL_REASON+= "${PKGNAME} uses X11, but ${X11BASE} not found"
.    else
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${X11BASE}
	${_PKG_SILENT}${_PKG_DEBUG}${CHOWN} ${ROOT_USER}:${ROOT_GROUP} ${X11BASE}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} ${PKGDIRMODE} ${X11BASE}
.    endif
.  endif
.  if defined(BROKEN)
PKG_FAIL_REASON+= "${PKGNAME} is marked as broken:" ${BROKEN:Q}
.  endif

.  if defined(LICENSE)
.    if defined(ACCEPTABLE_LICENSES) && !empty(ACCEPTABLE_LICENSES:M${LICENSE})
_ACCEPTABLE=	yes
.    endif	# ACCEPTABLE_LICENSES
.    if !defined(_ACCEPTABLE)
PKG_FAIL_REASON+= "${PKGNAME} has an unacceptable license: ${LICENSE}." \
	 "    To view the license, enter \"${MAKE} show-license\"." \
	 "    To indicate acceptance, add this line to your /etc/mk.conf:" \
	 "    ACCEPTABLE_LICENSES+=${LICENSE}"
.    endif	# _ACCEPTABLE
.  endif	# LICENSE

# Define __PLATFORM_OK only if the OS matches the pkg's allowed list.
.  if defined(ONLY_FOR_PLATFORM) && !empty(ONLY_FOR_PLATFORM)
.    for __tmp__ in ${ONLY_FOR_PLATFORM}
.      if ${MACHINE_PLATFORM:M${__tmp__}} != ""
__PLATFORM_OK?=	yes
.      endif	# MACHINE_PLATFORM
.    endfor	# __tmp__
.  else	# !ONLY_FOR_PLATFORM
__PLATFORM_OK?=	yes
.  endif	# ONLY_FOR_PLATFORM
.  for __tmp__ in ${NOT_FOR_PLATFORM}
.    if ${MACHINE_PLATFORM:M${__tmp__}} != ""
.      undef __PLATFORM_OK
.    endif	# MACHINE_PLATFORM
.  endfor	# __tmp__
.  if !defined(__PLATFORM_OK)
PKG_SKIP_REASON+= "${PKGNAME} is not available for ${MACHINE_PLATFORM}"
.  endif	# !__PLATFORM_OK

#
# Now print some error messages that we know we should ignore the pkg
#
.  if defined(PKG_FAIL_REASON) || defined(PKG_SKIP_REASON)
.PHONY: do-check-pkg-fail-or-skip-reason
fetch checksum extract patch configure all build install package \
update depends do-check-pkg-fail-or-skip-reason:
.    if defined(SKIP_SILENT)
	@${DO_NADA}
.    else
	@for str in ${PKG_FAIL_REASON} ${PKG_SKIP_REASON}; do		\
		${ECHO} "${_PKGSRC_IN}> $$str";				\
	done
.    endif
.    if defined(PKG_FAIL_REASON)
	@${FALSE}
.    endif
.  endif # SKIP
.endif # !NO_SKIP

.PHONY: do-check-pkg-fail-reason
do-check-pkg-fail-reason:
	@${DO_NADA}

# This target should appear as a dependency of every top level target that
# is intended to be called by the user or by a package different from the
# current package.
.if defined(PKG_FAIL_REASON)
do-check-pkg-fail-reason: do-check-pkg-fail-or-skip-reason
.endif

# Add these defs to the ones dumped into +BUILD_DEFS
BUILD_DEFS+=	PKGPATH
BUILD_DEFS+=	OPSYS OS_VERSION MACHINE_ARCH MACHINE_GNU_ARCH
BUILD_DEFS+=	CPPFLAGS CFLAGS FFLAGS LDFLAGS
BUILD_DEFS+=	CONFIGURE_ENV CONFIGURE_ARGS
BUILD_DEFS+=	OBJECT_FMT LICENSE RESTRICTED
BUILD_DEFS+=	NO_SRC_ON_FTP NO_SRC_ON_CDROM
BUILD_DEFS+=	NO_BIN_ON_FTP NO_BIN_ON_CDROM

.if defined(OSVERSION_SPECIFIC)
BUILD_DEFS+=	OSVERSION_SPECIFIC
.endif # OSVERSION_SPECIFIC

.PHONY: all
.if !target(all)
all: ${_PKGSRC_BUILD_TARGETS}
.endif

.if !defined(DEPENDS_TARGET)
.  if make(package)
DEPENDS_TARGET=	package
.  elif make(update)
.    if defined(UPDATE_TARGET) && ${UPDATE_TARGET} == "replace"
DEPENDS_TARGET=	${UPDATE_TARGET}
.    else
DEPENDS_TARGET=	update
.    endif
.  elif make(bin-install) || make(real-su-bin-install)
DEPENDS_TARGET=	bin-install
.  else
DEPENDS_TARGET=	reinstall
.  endif
.endif

.if !defined(UPDATE_TARGET)
.  if ${DEPENDS_TARGET} == "update"
.    if make(package)
UPDATE_TARGET=	package
.    else
UPDATE_TARGET=	install
.    endif
.  else
UPDATE_TARGET=	${DEPENDS_TARGET}
.  endif
.endif

UPDATE_RUNNING?=	NO

################################################################
# The following are used to create easy dummy targets for
# disabling some bit of default target behavior you don't want.
# They still check to see if the target exists, and if so don't
# do anything, since you might want to set this globally for a
# group of packages in a Makefile.inc, but still be able to
# override from an individual Makefile.
################################################################

# Disable checksum
.PHONY: checksum
.if (defined(NO_CHECKSUM) || exists(${_EXTRACT_COOKIE})) && !target(checksum)
checksum: fetch
	@${DO_NADA}
.endif

# Disable wrapper
.PHONY: wrapper
.if defined(NO_BUILD) && !target(wrapper)
wrapper: tools
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${_WRAPPER_COOKIE}
.endif

# Disable configure
.PHONY: configure
.if defined(NO_CONFIGURE) && !target(configure)
configure: wrapper
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${_CONFIGURE_COOKIE}
.endif

# Disable build
.PHONY: build
.if defined(NO_BUILD)
_build: configure
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${_BUILD_COOKIE}
.endif

################################################################
# More standard targets start here.
#
# These are the body of the build/install framework.  If you are
# not happy with the default actions, and you can't solve it by
# adding pre-* or post-* targets/scripts, override these.
################################################################

###
### _RESUME_TRANSFER:
###
### Macro to resume a previous transfer, needs to have defined
### the following options in mk.conf:
###
### PKG_RESUME_TRANSFERS
### FETCH_RESUME_ARGS (if FETCH_CMD != default)
### FETCH_OUTPUT_ARGS (if FETCH_CMD != default)
###
### For example if you want to use wget (pkgsrc/net/wget):
###
### FETCH_CMD=wget
### FETCH_RESUME_ARGS=-c
### FETCH_OUTPUT_ARGS=-O
###
### How does it work?
###
### FETCH_CMD downloads the file and saves it temporally into $$bfile.temp
### if the checksum match the correct one, $$bfile.temp is renamed to
### the original name.
###

_RESUME_TRANSFER=						\
	ofile="${DISTDIR}/${DIST_SUBDIR}/$$bfile";		\
	tfile="${DISTDIR}/${DIST_SUBDIR}/$$bfile.temp";		\
	tsize=`${AWK} '/^Size/ && $$2 == '"\"($$file)\""' { print $$4 }' ${DISTINFO_FILE}` || ${TRUE}; \
        osize=`${WC} -c < $$ofile`;				\
								\
	case "$$tsize" in					\
	"")	${ECHO_MSG} "No size in distinfo file (${DISTINFO_FILE})";	\
		break;;						\
	esac;							\
								\
	if [ "$$osize" -eq "$$tsize" ]; then			\
		if [ -f "$$tfile" ]; then			\
			${RM} $$tfile;				\
		fi;						\
		need_fetch=no;					\
	elif [ "$$osize" -lt "$$tsize" -a ! -f "$$tfile" ]; then	\
		${CP} $$ofile $$tfile;				\
		dsize=`${WC} -c < $$tfile`;			\
		need_fetch=yes;					\
	elif [ -f "$$tfile" -a "$$dsize" -gt "$$ossize" ]; then	\
		dsize=`${WC} -c < $$tfile`;			\
		need_fetch=yes;					\
	else							\
		if [ -f "$$tfile" ]; then			\
			dsize=`${WC} -c < $$tfile`;		\
		fi;						\
		need_fetch=yes;					\
	fi;							\
	if [ "$$need_fetch" = "no" ]; then			\
		break;						\
	elif [ -f "$$tfile" -a "$$dsize" -eq "$$tsize" ]; then	\
		${MV} $$tfile $$ofile;				\
		break;						\
	elif [ -n "$$ftp_proxy" -o -n "$$http_proxy" ]; then	\
		${ECHO_MSG} "===> Resume is not supported by ftp(1) using http/ftp proxies.";	\
		break;						\
	elif [ "$$need_fetch" = "yes" -a "$$dsize" -lt "$$tsize" ]; then	\
		if [ "${FETCH_CMD:T}" != "ftp" -a -z "${FETCH_RESUME_ARGS}" ]; then \
			${ECHO_MSG} "=> Resume transfers are not supported, FETCH_RESUME_ARGS is empty."; \
			break;					\
		else						\
			for res_site in $$sites; do		\
				if [ -z "${FETCH_OUTPUT_ARGS}" ]; then \
					${ECHO_MSG} "=> FETCH_OUTPUT_ARGS has to be defined."; \
					break;			\
				fi;				\
				${ECHO_MSG} "=> $$bfile not completed, resuming:";  \
				${ECHO_MSG} "=> Downloaded: $$dsize Total: $$tsize."; \
				${ECHO_MSG};			\
				cd ${DISTDIR};			\
				${FETCH_CMD} ${FETCH_BEFORE_ARGS} ${FETCH_RESUME_ARGS} \
					${FETCH_OUTPUT_ARGS} $${bfile}.temp $${res_site}$${bfile}; \
				if [ $$? -eq 0 ]; then		\
					ndsize=`${WC} -c < $$tfile`;    \
					if [ "$$tsize" -eq "$$ndsize" ]; then \
						${MV} $$tfile $$ofile;  \
					fi;			\
					break;			\
				fi;				\
			done;					\
		fi;						\
	elif [ "$$dsize" -gt "$$tsize" ]; then			\
		${ECHO_MSG} "==> Downloaded file larger than the recorded size."; \
		break;						\
	fi

#
# Define the elementary fetch macros.
#
_FETCH_FILE=								\
	if [ ! -f $$file -a ! -f $$bfile -a ! -h $$bfile ]; then	\
		${ECHO_MSG} "=> $$bfile doesn't seem to exist on this system."; \
		if [ ! -w ${_DISTDIR}/. ]; then 			\
			${ECHO_MSG} "=> Can't download to ${_DISTDIR} (permission denied?)."; \
			exit 1; 					\
		fi; 							\
		for site in $$sites; do					\
			${ECHO_MSG} "=> Attempting to fetch $$bfile from $${site}."; \
			if [ -f ${DISTINFO_FILE} ]; then		\
				${AWK} 'NF == 5 && $$1 == "Size" && $$2 == "('$$bfile')" { printf("=> [%s %s]\n", $$4, $$5) }' ${DISTINFO_FILE}; \
			fi;						\
			if ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${bfile} ${FETCH_AFTER_ARGS}; then \
				if [ -n "${FAILOVER_FETCH}" -a -f ${DISTINFO_FILE} -a -f ${_DISTDIR}/$$bfile ]; then \
					alg=`${AWK} 'NF == 4 && $$2 == "('$$file')" && $$3 == "=" {print $$1; exit}' ${DISTINFO_FILE}`; \
					if [ -z "$$alg" ]; then		\
						alg=${PATCH_DIGEST_ALGORITHM};\
					fi;				\
					CKSUM=`${DIGEST} $$alg < ${_DISTDIR}/$$bfile`; \
					CKSUM2=`${AWK} '$$1 == "'$$alg'" && $$2 == "('$$file')" {print $$4; exit}' <${DISTINFO_FILE}`; \
					if [ "$$CKSUM" = "$$CKSUM2" -o "$$CKSUM2" = "IGNORE" ]; then \
						break;			\
					else				\
						${ECHO_MSG} "=> Checksum failure - trying next site."; \
					fi;				\
				elif [ ! -f ${_DISTDIR}/$$bfile ]; then \
					${ECHO_MSG} "=> FTP didn't fetch expected file, trying next site." ; \
				else					\
					break;				\
				fi;					\
			fi						\
		done;							\
		if [ ! -f ${_DISTDIR}/$$bfile ]; then			\
			${ECHO_MSG} "=> Couldn't fetch $$bfile - please try to retrieve this";\
			${ECHO_MSG} "=> file manually into ${_DISTDIR} and try again."; \
			exit 1;						\
		fi;							\
	fi

_CHECK_DIST_PATH=							\
	if [ "X${DIST_PATH}" != "X" ]; then				\
		for d in "" ${DIST_PATH:S/:/ /g}; do			\
			case $$d in "" | ${DISTDIR}) continue;; esac;	\
			if [ -f $$d/${DIST_SUBDIR}/$$bfile ]; then	\
				${ECHO} "Using $$d/${DIST_SUBDIR}/$$bfile"; \
				${RM} -f $$bfile;			\
				${LN} -s $$d/${DIST_SUBDIR}/$$bfile $$bfile; \
				break;					\
			fi;						\
		done;							\
	fi

#
# Set up ORDERED_SITES to work out the exact list of sites for every file,
# using the dynamic sites script, or sorting according to the master site
# list or the patterns in MASTER_SORT or MASTER_SORT_REGEX as appropriate.
# No actual sorting is done until ORDERED_SITES is expanded.
#
.if defined(MASTER_SORT) || defined(MASTER_SORT_REGEX)
MASTER_SORT?=
MASTER_SORT_REGEX?=
MASTER_SORT_REGEX+= ${MASTER_SORT:S/./\\./g:C/.*/:\/\/[^\/]*&\//}

MASTER_SORT_AWK= BEGIN { RS = " "; ORS = " "; IGNORECASE = 1 ; gl = "${MASTER_SORT_REGEX:S/\\/\\\\/g}"; }
.  for srt in ${MASTER_SORT_REGEX}
MASTER_SORT_AWK+= /${srt:C/\//\\\//g}/ { good["${srt:S/\\/\\\\/g}"] = good["${srt:S/\\/\\\\/g}"] " " $$0 ; next; }
.  endfor
MASTER_SORT_AWK+= { rest = rest " " $$0; } END { n=split(gl, gla); for(i=1;i<=n;i++) { print good[gla[i]]; } print rest; }

SORT_SITES_CMD= ${ECHO} $$unsorted_sites | ${AWK} '${MASTER_SORT_AWK}'
ORDERED_SITES= ${_MASTER_SITE_OVERRIDE} `${SORT_SITES_CMD:S/\\/\\\\/g:C/"/\"/g}`
.else
ORDERED_SITES= ${_MASTER_SITE_OVERRIDE} $$unsorted_sites
.endif

#
# Associate each file to fetch with the correct site(s).
#
.if defined(DYNAMIC_MASTER_SITES)
.  for fetchfile in ${_ALLFILES}
SITES_${fetchfile:T:S/=/--/}?= `${SH} ${FILESDIR}/getsite.sh ${fetchfile:T}`
SITES.${fetchfile:T:S/=/--/}?=	${SITES_${fetchfile:T:S/=/--/}}
.  endfor
.endif
.if !empty(_DISTFILES)
.  for fetchfile in ${_DISTFILES}
SITES_${fetchfile:T:S/=/--/}?= ${MASTER_SITES}
SITES.${fetchfile:T:S/=/--/}?=	${SITES_${fetchfile:T:S/=/--/}}
.  endfor
.endif
.if !empty(_PATCHFILES)
.  for fetchfile in ${_PATCHFILES}
SITES_${fetchfile:T:S/=/--/}?= ${PATCH_SITES}
SITES.${fetchfile:T:S/=/--/}?=	${SITES_${fetchfile:T:S/=/--/}}
.  endfor
.endif

# This code is only called in a batch case, to check for the presence of
# the distfiles
.PHONY: batch-check-distfiles
batch-check-distfiles:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	gotfiles=yes;							\
	for file in "" ${_ALLFILES}; do					\
		case "$$file" in					\
		"")	continue ;;					\
		*)	if [ ! -f ${DISTDIR}/$$file ]; then		\
				gotfiles=no;				\
			fi ;;						\
		esac;							\
	done;								\
	case "$$gotfiles" in						\
	no)	${ECHO} "*** This package requires user intervention to download the distfiles"; \
		${ECHO} "*** Please fetch the distfiles manually and place them in"; \
		${ECHO} "*** ${DISTDIR}";				\
		[ ! -z "${MASTER_SITES}" ] &&				\
			${ECHO} "*** The distfiles are available from ${MASTER_SITES}";	\
		[ ! -z "${HOMEPAGE}" ] && 				\
			${ECHO} "*** See ${HOMEPAGE} for more details";	\
		${ECHO};						\
		${TOUCH} ${_INTERACTIVE_COOKIE};			\
		${FALSE} ;;						\
	esac

.PHONY: do-fetch
.if !target(do-fetch)
do-fetch:
.  if !defined(ALLOW_VULNERABLE_PACKAGES)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${PKGVULNDIR}/pkg-vulnerabilities ]; then		\
		${ECHO_MSG} "${_PKGSRC_IN}> Checking for vulnerabilities in ${PKGNAME}"; \
		vul=`${MAKE} ${MAKEFLAGS} check-vulnerable`;		\
		case "$$vul" in						\
		"")	;;						\
		*)	${ECHO} "$$vul";				\
			${ECHO} "or define ALLOW_VULNERABLE_PACKAGES if this package is absolutely essential"; \
			${FALSE} ;;					\
		esac;							\
	else								\
		${ECHO_MSG} "${_PKGSRC_IN}> *** No ${PKGVULNDIR}/pkg-vulnerabilities file found,"; \
		${ECHO_MSG} "${_PKGSRC_IN}> *** skipping vulnerability checks. To fix, install"; \
		${ECHO_MSG} "${_PKGSRC_IN}> *** the pkgsrc/security/audit-packages package and run"; \
		${ECHO_MSG} "${_PKGSRC_IN}> *** '${LOCALBASE}/sbin/download-vulnerability-list'."; \
	fi
.  endif
.  if !empty(_ALLFILES)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} -d ${_DISTDIR} || ${MKDIR} ${_DISTDIR}
.    if !empty(INTERACTIVE_STAGE:Mfetch) && defined(BATCH)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${MAKE} ${MAKEFLAGS} batch-check-distfiles
.    else
.      for fetchfile in ${_ALLFILES}
.        if defined(FETCH_MESSAGE) && !empty(FETCH_MESSAGE)
	${_PKG_SILENT}${_PKG_DEBUG} set -e;				\
	${TEST} -f ${DISTDIR:Q}/${fetchfile:Q} || {			\
		h="==============="; h="$$h$$h$$h$$h$$h";		\
		${ECHO} "$$h"; ${ECHO} "";				\
		for l in ${FETCH_MESSAGE}; do ${ECHO} "$$l"; done;	\
		${ECHO} ""; ${ECHO} "$$h";				\
		exit 1;							\
	}
.        elif defined(_FETCH_MESSAGE)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	file="${fetchfile}";						\
	if [ ! -f ${DISTDIR}/$$file ]; then				\
		${_FETCH_MESSAGE};					\
	fi
.        else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${_DISTDIR};							\
	file="${fetchfile}";						\
	bfile="${fetchfile:T}";						\
	unsorted_sites="${SITES.${fetchfile:T:S/=/--/}} ${_MASTER_SITE_BACKUP}"; \
	sites="${ORDERED_SITES}";					\
	${_CHECK_DIST_PATH};						\
	 if ${TEST} "${PKG_RESUME_TRANSFERS:M[Yy][Ee][Ss]}" ; then	\
	 	${_FETCH_FILE}; ${_RESUME_TRANSFER};			\
	 else								\
	 	${_FETCH_FILE};						\
	 fi
.        endif # defined(_FETCH_MESSAGE)
.      endfor
.    endif # INTERACTIVE_STAGE == fetch
.  endif # !empty(_ALLFILES)
.endif

.PHONY: show-distfiles
.if !target(show-distfiles)
show-distfiles:
.  if defined(PKG_FAIL_REASON)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.  else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for file in "" ${_CKSUMFILES}; do				\
		if [ "X$$file" = "X" ]; then continue; fi;		\
		${ECHO} $$file;						\
	done
.  endif
.endif

# Extract

# pkgsrc coarse-grained locking definitions and targets
acquire-lock: .USE
	${_ACQUIRE_LOCK}
release-lock: .USE
	${_RELEASE_LOCK}

.if ${PKGSRC_LOCKTYPE} == "none"
_ACQUIRE_LOCK=	@${DO_NADA}
_RELEASE_LOCK=	@${DO_NADA}
.else
LOCKFILE=	${WRKDIR}/.lockfile

_ACQUIRE_LOCK=								\
	${_PKG_SILENT}${_PKG_DEBUG}					\
	SHLOCK=${SHLOCK:Q};						\
	if ${TEST} ! -f "$$SHLOCK" || ${TEST} ! -x "$$SHLOCK"; then	\
		{ ${ECHO} "The \"$$SHLOCK\" utility does not exist, and is necessary for locking."; \
		  ${ECHO} "Please \""${MAKE:Q}" install\" in ../../pkgtools/shlock."; \
		} 1>&2;							\
		${FALSE};						\
	fi;								\
	if ${TEST} x${OBJHOSTNAME:Ddefined} != x"defined"; then		\
		${ECHO} "PKGSRC_LOCKTYPE needs OBJHOSTNAME defined." 1>&2; \
		${FALSE};						\
	fi;								\
	ppid=`${PS} -p $$$$ -o ppid | ${AWK} 'NR == 2 { print $$1 }'`;	\
	if ${TEST} "$$ppid" = ""; then					\
		${ECHO} "No parent process ID found.";			\
		${FALSE};						\
	fi;								\
	while true; do							\
		: "Remove lock files older than the last reboot";	\
		if ${TEST} -f /var/run/dmesg.boot -a -f ${LOCKFILE}; then \
			rebooted=`${FIND} /var/run/dmesg.boot -newer ${LOCKFILE} -print`; \
			if ${TEST} x"$$rebooted" != x; then		\
				${ECHO} "=> Removing stale ${LOCKFILE}"; \
				${RM} ${LOCKFILE};			\
			fi;						\
		fi;							\
		${SHLOCK} -f ${LOCKFILE} -p $$ppid && break;		\
		${ECHO} "=> Lock is held by pid `cat ${LOCKFILE}`";	\
		case "${PKGSRC_LOCKTYPE}" in				\
		once)	exit 1 ;;					\
		sleep)	${SLEEP} ${PKGSRC_SLEEPSECS} ;;			\
		esac							\
	done;								\
	if [ "${PKG_VERBOSE}" != "" ]; then				\
		${ECHO_MSG} "=> Lock acquired on behalf of process $$ppid"; \
	fi

_RELEASE_LOCK=								\
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ "${PKG_VERBOSE}" != "" ]; then				\
		${ECHO_MSG} "=> Lock released on behalf of process `${CAT} ${LOCKFILE}`"; \
	fi;								\
	${RM} ${LOCKFILE}
.endif # PKGSRC_LOCKTYPE

${WRKDIR}:
.if !defined(KEEP_WRKDIR)
.  if ${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once"
.    if !exists(${LOCKFILE})
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKDIR}
.    endif
.  endif
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${WRKDIR}
.if defined(WRKOBJDIR)
.  if ${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once"
.    if !exists(${LOCKFILE})
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR_BASENAME} || ${TRUE}
.    endif
.  endif
.  if !empty(CREATE_WRKDIR_SYMLINK:M[Yy][Ee][Ss])
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${LN} -s ${WRKDIR} ${WRKDIR_BASENAME} 2>/dev/null; then	\
		${ECHO} "${WRKDIR_BASENAME} -> ${WRKDIR}";		\
	fi
.  endif
.endif # WRKOBJDIR

# Configure

# _CONFIGURE_PREREQ is a list of targets to run after pre-configure but before
#	do-configure.  These targets typically edit the files used by the
#	do-configure target.  The targets are run as dependencies of
#	pre-configure-override.
#
# _CONFIGURE_POSTREQ is a list of targets to run after do-configure but before
#	post-configure.  These targets typically edit the files generated by
#	the do-configure target that are used during the build phase.

.if defined(USE_PKGLOCALEDIR)
_PKGLOCALEDIR=			${PREFIX}/${PKGLOCALEDIR}/locale
REPLACE_LOCALEDIR_PATTERNS?=	# empty
_REPLACE_LOCALEDIR_PATTERNS=	${REPLACE_LOCALEDIR_PATTERNS}
.  if defined(HAS_CONFIGURE) || defined(GNU_CONFIGURE)
_REPLACE_LOCALEDIR_PATTERNS+=	[Mm]akefile.in*
.  else
_REPLACE_LOCALEDIR_PATTERNS+=	[Mm]akefile*
.  endif
_REPLACE_LOCALEDIR_PATTERNS_FIND_cmd= \
	cd ${WRKSRC} && \
	${ECHO} "__dummy-entry__" && \
	${FIND} . \( ${_REPLACE_LOCALEDIR_PATTERNS:C/.*/-o -name "&"/g:S/-o//1} \) -print \
	| ${SED} -e 's|^\./||' \
	| ${SORT} -u
REPLACE_LOCALEDIR?=	# empty
_REPLACE_LOCALEDIR=	\
	${REPLACE_LOCALEDIR}						\
	${_REPLACE_LOCALEDIR_PATTERNS_FIND_cmd:sh:N__dummy-entry__:N*.orig}

_CONFIGURE_PREREQ+=		subst-pkglocaledir
.  if empty(USE_PKGLOCALEDIR:M[nN][oO])
SUBST_CLASSES+=			pkglocaledir
.  endif
SUBST_MESSAGE.pkglocaledir=	Fixing locale directory references.
SUBST_FILES.pkglocaledir=	${_REPLACE_LOCALEDIR}
SUBST_SED.pkglocaledir=		\
	-e 's|^\(localedir[ 	:]*=\).*|\1 ${_PKGLOCALEDIR}|'		\
	-e 's|^\(gnulocaledir[ 	:]*=\).*|\1 ${_PKGLOCALEDIR}|'		\
	-e 's|\(-DLOCALEDIR[ 	]*=\)[^ 	]*\(\.\*\)|\1"\\"${_PKGLOCALEDIR}\\""\2|'
.endif

.if defined(REPLACE_PERL)
REPLACE_INTERPRETER+=	perl
REPLACE.perl.old=	.*/bin/perl
REPLACE.perl.new=	${PERL5}
REPLACE_FILES.perl=	${REPLACE_PERL}
.endif

.if defined(REPLACE_INTERPRETER)

# After 2006Q2, all instances of _REPLACE.* and _REPLACE_FILES.* should
# have been replaced with REPLACE.* and REPLACE_FILES.*. This code is
# then no longer needed.
.  for _lang_ in ${REPLACE_INTERPRETER}
REPLACE.${_lang_}.old?=		${_REPLACE.${_lang_}.old}
REPLACE.${_lang_}.new?=		${_REPLACE.${_lang_}.new}
REPLACE_FILES.${_lang_}?=	${_REPLACE_FILES.${_lang_}}
.  endfor

_CONFIGURE_PREREQ+=	replace-interpreter
.PHONY: replace-interpreter
replace-interpreter:
.  for lang in ${REPLACE_INTERPRETER}
.    for pattern in ${REPLACE_FILES.${lang}}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${WRKSRC};							\
	for f in ${pattern}; do						\
	    if [ -f $${f} ]; then					\
		    ${SED} -e '1s|^#!${REPLACE.${lang}.old}|#!${REPLACE.${lang}.new}|' \
			    $${f} > $${f}.new;				\
		    if [ -x $${f} ]; then				\
			    ${CHMOD} a+x $${f}.new;			\
		    fi;							\
		    ${MV} -f $${f}.new $${f};				\
	    else							\
		${ECHO_MSG} "[bsd.pkg.mk:replace-interpreter] WARNING: Skipping non-existent file \"$$f\"." 1>&2; \
	    fi;								\
	done
.    endfor
.  endfor
.endif

.if defined(USE_LIBTOOL) && defined(LTCONFIG_OVERRIDE)
_CONFIGURE_PREREQ+=	do-ltconfig-override
.PHONY: do-ltconfig-override
do-ltconfig-override:
.  for ltconfig in ${LTCONFIG_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${ltconfig} ]; then					\
		${RM} -f ${ltconfig};					\
		${ECHO} "${RM} -f libtool; ${LN} -s ${_LIBTOOL} libtool" \
			> ${ltconfig};					\
		${CHMOD} +x ${ltconfig};				\
	fi
.  endfor
.endif

_CONFIGURE_PREREQ+=	do-config-star-override
.PHONY: do-config-star-override
do-config-star-override:
.if defined(GNU_CONFIGURE)
.  if !empty(CONFIG_GUESS_OVERRIDE)
.    for _pattern_ in ${CONFIG_GUESS_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for file in ${_pattern_}; do					\
		if [ -f "$$file" ]; then				\
			${RM} -f $$file;				\
			${LN} -s ${PKGSRCDIR}/mk/gnu-config/config.guess \
				$$file;					\
		fi;							\
	done
.    endfor
.  endif
.  if !empty(CONFIG_SUB_OVERRIDE)
.    for _pattern_ in ${CONFIG_SUB_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for file in ${_pattern_}; do					\
		if [ -f "$$file" ]; then				\
			${RM} -f $$file;				\
			${LN} -s ${PKGSRCDIR}/mk/gnu-config/config.sub	\
				$$file;					\
		fi;							\
	done
.    endfor
.  endif
.  if !empty(CONFIG_RPATH_OVERRIDE)
.    for _pattern_ in ${CONFIG_RPATH_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for file in ${_pattern_}; do					\
		if [ -f "$$file" ]; then				\
			${RM} -f $$file;				\
			${LN} -s ${PKGSRCDIR}/mk/gnu-config/config.rpath \
				$$file;					\
		fi;							\
	done
.    endfor
.  endif
.endif

.if defined(CONFIGURE_SCRIPTS_OVERRIDE)
_CONFIGURE_PREREQ+=	do-configure-scripts-override
.PHONY: do-configure-scripts-override
do-configure-scripts-override:
.  for _pattern_ in ${CONFIGURE_SCRIPTS_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for file in ${_pattern_}; do					\
		if ${TEST} -f "$$file"; then				\
			${AWK} '/ *-recheck *\| *--recheck.*\)/ {	\
					print;				\
					print "    # Avoid regenerating for rechecks on pkgsrc"; \
					print "    exit 0";		\
					next;				\
				}					\
				{ print }' $$file > $$file.override &&	\
			${CHMOD} +x $$file.override &&			\
			${MV} -f $$file.override $$file;		\
		fi;							\
	done
.  endfor
.endif

PKGCONFIG_OVERRIDE_SED= \
	'/^Libs:.*[ 	]/s|-L\([ 	]*[^ 	]*\)|${COMPILER_RPATH_FLAG}\1 -L\1|g'
PKGCONFIG_OVERRIDE_STAGE?=	pre-configure

.if defined(PKGCONFIG_OVERRIDE) && !empty(PKGCONFIG_OVERRIDE)
.  if ${PKGCONFIG_OVERRIDE_STAGE} == "pre-configure"
_CONFIGURE_PREREQ+=		subst-pkgconfig
.  elif ${PKGCONFIG_OVERRIDE_STAGE} == "post-configure"
_CONFIGURE_POSTREQ+=		subst-pkgconfig
.  else
SUBST_STAGE.pkgconfig=		${PKGCONFIG_OVERRIDE_STAGE}
.  endif
SUBST_CLASSES+=			pkgconfig
SUBST_MESSAGE.pkgconfig=	Adding rpaths to pkgconfig files.
SUBST_FILES.pkgconfig=		${PKGCONFIG_OVERRIDE:S/^${WRKSRC}\///}
SUBST_SED.pkgconfig=		${PKGCONFIG_OVERRIDE_SED}
.endif

# By adding this target, it makes sure the above PREREQ's work.
.PHONY: pre-configure-override
pre-configure-override: ${_CONFIGURE_PREREQ}
	@${DO_NADA}

.PHONY: do-configure
.if !target(do-configure)
do-configure:
.  if defined(HAS_CONFIGURE)
.    for _dir_ in ${CONFIGURE_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}			\
	cd ${WRKSRC} && cd ${_dir_} &&					\
	${SETENV}							\
	    AWK=${TOOLS_AWK:Q}						\
	    INSTALL=${INSTALL:Q}\ -c\ -o\ ${BINOWN}\ -g\ ${BINGRP}	\
	    ac_given_INSTALL=${INSTALL:Q}\ -c\ -o\ ${BINOWN}\ -g\ ${BINGRP} \
	    INSTALL_DATA=${INSTALL_DATA:Q}				\
	    INSTALL_PROGRAM=${INSTALL_PROGRAM:Q}			\
	    INSTALL_GAME=${INSTALL_GAME:Q}				\
	    INSTALL_GAME_DATA=${INSTALL_GAME_DATA:Q}			\
	    INSTALL_SCRIPT=${INSTALL_SCRIPT:Q}				\
	    ${CONFIGURE_ENV} ${CONFIG_SHELL}				\
	    ${CONFIGURE_SCRIPT} ${CONFIGURE_ARGS}
.    endfor
.  endif
.  if defined(USE_IMAKE)
.    for _dir_ in ${CONFIGURE_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${WRKSRC}; cd ${_dir_};					\
	${SETENV} ${SCRIPTS_ENV} XPROJECTROOT=${X11BASE} ${XMKMF}
.    endfor
.  endif
.endif

.if defined(USE_LIBTOOL) && \
    (defined(LIBTOOL_OVERRIDE) || defined(SHLIBTOOL_OVERRIDE))
_CONFIGURE_POSTREQ+=	do-libtool-override
.PHONY: do-libtool-override
do-libtool-override:
.  if defined(LIBTOOL_OVERRIDE)
.    for _pattern_ in ${LIBTOOL_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for file in ${_pattern_}; do					\
		if [ -f "$$file" ]; then				\
			${RM} -f $$file;				\
			(${ECHO} '#!${CONFIG_SHELL}';			\
		 	 ${ECHO} 'exec ${_LIBTOOL} "$$@"';		\
			) > $$file;					\
			${CHMOD} +x $$file;				\
		fi;							\
	done
.    endfor
.  endif
.  if defined(SHLIBTOOL_OVERRIDE)
.    for _pattern_ in ${SHLIBTOOL_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC};			\
	for file in ${_pattern_}; do					\
		if [ -f "$$file" ]; then				\
			${RM} -f $$file;				\
			(${ECHO} '#!${CONFIG_SHELL}';			\
		 	 ${ECHO} 'exec ${_SHLIBTOOL} "$$@"';		\
			) > $$file;					\
			${CHMOD} +x $$file;				\
		fi;							\
	done
.    endfor
.  endif
.endif

.PHONY: post-configure
post-configure: ${_CONFIGURE_POSTREQ}

# Build

BUILD_DIRS?=		${CONFIGURE_DIRS}
BUILD_MAKE_FLAGS?=	${MAKE_FLAGS}

.PHONY: do-build
.if !target(do-build)
do-build:
.  for _dir_ in ${BUILD_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}			\
	cd ${WRKSRC} && cd ${_dir_} &&					\
	${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${BUILD_MAKE_FLAGS}	\
		-f ${MAKEFILE} ${BUILD_TARGET}
.  endfor
.endif

#Test

TEST_DIRS?=		${BUILD_DIRS}
TEST_ENV+=		${MAKE_ENV}
TEST_MAKE_FLAGS?=	${MAKE_FLAGS}

.PHONY: do-test
.if !target(do-test)
do-test:
.  if defined(TEST_TARGET) && !empty(TEST_TARGET)
.    for _dir_ in ${TEST_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}			\
	cd ${WRKSRC} && cd ${_dir_} &&					\
	${SETENV} ${TEST_ENV} ${MAKE_PROGRAM} ${TEST_MAKE_FLAGS}	\
		-f ${MAKEFILE} ${TEST_TARGET}
.    endfor
.  else
	@${DO_NADA}
.  endif
.endif

.include "${PKGSRCDIR}/mk/flavor/bsd.flavor.mk"

# Dependencies
.include "${PKGSRCDIR}/mk/depends/bsd.depends.mk"

# Check
.include "${PKGSRCDIR}/mk/check/bsd.check.mk"

# Clean
.include "../../mk/bsd.pkg.clean.mk"

# Install
.include "${PKGSRCDIR}/mk/install/bsd.install.mk"

# Package
.include "${PKGSRCDIR}/mk/package/bsd.package.mk"

.PHONY: acquire-tools-lock
.PHONY: acquire-wrapper-lock acquire-configure-lock acquire-build-lock
acquire-tools-lock:
	${_ACQUIRE_LOCK}
acquire-wrapper-lock:
	${_ACQUIRE_LOCK}
acquire-configure-lock:
	${_ACQUIRE_LOCK}
acquire-build-lock:
	${_ACQUIRE_LOCK}

.PHONY: release-tools-lock
.PHONY: release-wrapper-lock release-configure-lock release-build-lock
release-tools-lock:
	${_RELEASE_LOCK}
release-wrapper-lock:
	${_RELEASE_LOCK}
release-configure-lock:
	${_RELEASE_LOCK}
release-build-lock:
	${_RELEASE_LOCK}

################################################################
# Skeleton targets start here
#
# You shouldn't have to change these.  Either add the pre-* or
# post-* targets/scripts or redefine the do-* targets.  These
# targets don't do anything other than checking for cookies and
# call the necessary targets/scripts.
################################################################

.PHONY: fetch
.if !target(fetch)
fetch:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-fetch PKG_PHASE=fetch
.endif

.PHONY: tools
.if !target(tools)
tools: patch acquire-tools-lock ${_TOOLS_COOKIE} release-tools-lock
.endif

.PHONY: wrapper
.if !target(wrapper)
wrapper: tools acquire-wrapper-lock ${_WRAPPER_COOKIE} release-wrapper-lock
.endif

.PHONY: configure
.if !target(configure)
configure: wrapper acquire-configure-lock ${_CONFIGURE_COOKIE} release-configure-lock
.endif

.PHONY: _build
.if !target(_build)
_build: configure acquire-build-lock ${_BUILD_COOKIE} release-build-lock
.endif

.PHONY: build
build: pkginstall

.PHONY: test
.if !target(test)
test: build ${_TEST_COOKIE}
.endif

${_TOOLS_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-tools PKG_PHASE=tools

${_WRAPPER_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${BUILD_ENV} ${MAKE} ${MAKEFLAGS} real-wrapper PKG_PHASE=wrapper

PKG_ERROR_CLASSES+=	configure
PKG_ERROR_MSG.configure=						\
	""								\
	"There was an error during the \`\`configure'' phase."		\
	"Please investigate the following for more information:"
.if defined(GNU_CONFIGURE)
PKG_ERROR_MSG.configure+=						\
	"     * config.log"						\
	"     * ${WRKLOG}"						\
	""
.else
PKG_ERROR_MSG.configure+=						\
	"     * log of the build"					\
	"     * ${WRKLOG}"						\
	""
.endif
.if defined(BROKEN_IN)
PKG_ERROR_MSG.configure+=						\
	"     * This package is broken in ${BROKEN_IN}."		\
	"     * It may be removed in the next branch unless fixed."
.endif
${_CONFIGURE_COOKIE}:
.if !empty(INTERACTIVE_STAGE:Mconfigure) && defined(BATCH)
	@${ECHO} "*** The configuration stage of this package requires user interaction"
	@${ECHO} "*** Please configure manually with \"cd ${PKGDIR} && ${MAKE} configure\""
	@${TOUCH} ${_INTERACTIVE_COOKIE}
	@${FALSE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${BUILD_ENV} ${MAKE} ${MAKEFLAGS} real-configure PKG_PHASE=configure || ${PKG_ERROR_HANDLER.configure}
.endif

PKG_ERROR_CLASSES+=	build
PKG_ERROR_MSG.build=	\
	""								\
	"There was an error during the \`\`build'' phase."		\
	"Please investigate the following for more information:"	\
	"     * log of the build"					\
	"     * ${WRKLOG}"						\
	""
.if defined(BROKEN_IN)
PKG_ERROR_MSG.build+=							\
	"     * This package is broken in ${BROKEN_IN}."		\
	"     * It may be removed in the next branch unless fixed."
.endif
${_BUILD_COOKIE}:
.if !empty(INTERACTIVE_STAGE:Mbuild) && defined(BATCH)
	@${ECHO} "*** The build stage of this package requires user interaction"
	@${ECHO} "*** Please build manually with \"cd ${PKGDIR} && ${MAKE} build\""
	@${TOUCH} ${_INTERACTIVE_COOKIE}
	@${FALSE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${BUILD_ENV} ${MAKE} ${MAKEFLAGS} real-build PKG_PHASE=build || ${PKG_ERROR_HANDLER.build}
.endif

${_TEST_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${BUILD_ENV} ${MAKE} ${MAKEFLAGS} real-test PKG_PHASE=test

.PHONY: tools-message wrapper-message
.PHONY: configure-message build-message test-message
tools-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Overriding tools for ${PKGNAME}"
wrapper-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Creating toolchain wrappers for ${PKGNAME}"
configure-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Configuring for ${PKGNAME}"
build-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Building for ${PKGNAME}"
test-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Testing for ${PKGNAME}"

.PHONY: tools-cookie wrapper-cookie
.PHONY: configure-cookie build-cookie test-cookie
tools-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${_TOOLS_COOKIE}
wrapper-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${_WRAPPER_COOKIE}
configure-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${_CONFIGURE_COOKIE}
build-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${_BUILD_COOKIE}
test-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${_TEST_COOKIE}

.ORDER: pre-fetch do-fetch post-fetch
.ORDER: tools-message tools-vars pre-tools do-tools post-tools tools-cookie
.ORDER: wrapper-message wrapper-vars pre-wrapper do-wrapper post-wrapper wrapper-cookie
.ORDER: configure-message configure-vars pre-configure pre-configure-override do-configure post-configure configure-cookie
.ORDER: build-message build-vars pre-build do-build post-build build-cookie
.ORDER: test-message pre-test do-test post-test test-cookie

# Please note that the order of the following targets is important, and
# should not be modified (.ORDER is not recognised by make(1) in a serial
# make i.e. without -j n)
.PHONY: real-fetch
.PHONY: real-tools real-wrapper
.PHONY: real-configure real-build real-test
real-fetch: pre-fetch do-fetch post-fetch
real-tools: tools-message tools-vars pre-tools do-tools post-tools tools-cookie
real-wrapper: wrapper-message wrapper-vars pre-wrapper do-wrapper post-wrapper wrapper-cookie
real-configure: configure-message configure-vars pre-configure pre-configure-override do-configure post-configure configure-cookie
real-build: build-message build-vars pre-build do-build post-build build-cookie
real-test: test-message pre-test do-test post-test test-cookie

# su-target is a macro target that does just-in-time su-to-root before
# reinvoking the make process as root.  It acquires root privileges and
# invokes a new make process with the target named "su-${.TARGET}".
#
.PHONY: su-target
su-target: .USE
	${_PKG_SILENT}${_PKG_DEBUG}					\
	case ${PRE_CMD.su-${.TARGET}:Q}"" in				\
	"")	;;							\
	*)	${PRE_CMD.su-${.TARGET}} ;;				\
	esac;								\
	if ${TEST} `${ID} -u` = `${ID} -u ${ROOT_USER}`; then		\
		${MAKE} ${MAKEFLAGS} PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL:Q} su-${.TARGET} ${MAKEFLAGS.${.TARGET}}; \
	else								\
		case ${PRE_ROOT_CMD:Q}"" in				\
		${TRUE:Q}"")	;;					\
		*) ${ECHO} "*** WARNING *** Running: "${PRE_ROOT_CMD:Q} ;; \
		esac;							\
		${PRE_ROOT_CMD};					\
		${ECHO_MSG} "${_PKGSRC_IN}> Becoming \`\`${ROOT_USER}'' to make su-${.TARGET} (`${ECHO} ${SU_CMD} | ${AWK} '{ print $$1 }'`)"; \
		${SU_CMD} "cd ${.CURDIR}; ${SETENV} PATH='$${PATH}:${SU_CMD_PATH_APPEND}' ${MAKE} ${MAKEFLAGS} PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL} su-${.TARGET} ${MAKEFLAGS.su-${.TARGET}}"; \
		${ECHO_MSG} "${_PKGSRC_IN}> Dropping \`\`${ROOT_USER}'' privileges."; \
	fi

# Empty pre-* and post-* targets

.for name in fetch tools wrapper configure build test

.  if !target(pre-${name})
pre-${name}:
	@${DO_NADA}
.  endif

.  if !target(post-${name})
post-${name}:
	@${DO_NADA}
.  endif

.endfor

################################################################
# Some more targets supplied for users' convenience
################################################################

# Run pkglint:
.PHONY: lint
lint:
	${_PKG_SILENT}${_PKG_DEBUG}${LOCALBASE}/bin/pkglint

# This is for the use of sites which store distfiles which others may
# fetch - only fetch the distfile if it is allowed to be
# re-distributed freely
.PHONY: mirror-distfiles
mirror-distfiles:
.if !defined(NO_SRC_ON_FTP)
	@${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} fetch NO_SKIP=yes
.endif


# Cleaning up

.PHONY: pre-distclean
.if !target(pre-distclean)
pre-distclean:
	@${DO_NADA}
.endif

.PHONY: distclean
.if !target(distclean)
distclean: pre-distclean clean
	${_PKG_SILENT}${ECHO_MSG} "${_PKGSRC_IN}> Dist cleaning for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${_DISTDIR} ]; then		\
		cd ${_DISTDIR} &&					\
		${TEST} -z "${DISTFILES}" || ${RM} -f ${DISTFILES};	\
                if [ "${PKG_RESUME_TRANSFERS:M[Yy][Ee][Ss]}" ]; then    \
                    ${TEST} -z "${DISTFILES}.temp" || ${RM} -f ${DISTFILES}.temp;    \
                fi;                                                     \
		${TEST} -z "${PATCHFILES}" || ${RM} -f ${PATCHFILES};	\
	fi
.  if defined(DIST_SUBDIR) && exists(DIST_SUBDIR)
	-${_PKG_SILENT}${_PKG_DEBUG}${RMDIR} ${_DISTDIR}
.  endif
	-${_PKG_SILENT}${_PKG_DEBUG}${RM} -f README.html
.endif

# Prints out a script to fetch all needed files (no checksumming).
.PHONY: fetch-list
.if !target(fetch-list)

fetch-list:
	@${ECHO} '#!/bin/sh'
	@${ECHO} '#'
	@${ECHO} '# This is an auto-generated script, the result of running'
	@${ECHO} '# `${MAKE} fetch-list'"'"' in directory "'"`${PWD_CMD}`"'"'
	@${ECHO} '# on host "'"`${UNAME} -n`"'" on "'"`date`"'".'
	@${ECHO} '#'
	@${MAKE} ${MAKEFLAGS} fetch-list-recursive
.endif # !target(fetch-list)

.PHONY: fetch-list-recursive
.if !target(fetch-list-recursive)

fetch-list-recursive:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for dir in `${MAKE} ${MAKEFLAGS} show-all-depends-dirs`; do	\
		(cd ../../$$dir &&					\
		${MAKE} ${MAKEFLAGS} fetch-list-one-pkg			\
		| ${AWK} '						\
		/^[^#]/ { FoundSomething = 1 }				\
		/^unsorted/ { gsub(/[[:space:]]+/, " \\\n\t") }		\
		/^echo/ { gsub(/;[[:space:]]+/, "\n") }			\
		{ block[line_c++] = $$0 }				\
		END { if (FoundSomething)				\
			for (line = 0; line < line_c; line++)		\
				print block[line] }			\
		')							\
	done
.endif # !target(fetch-list-recursive)

.PHONY: fetch-list-one-pkg
.if !target(fetch-list-one-pkg)

fetch-list-one-pkg:
.  if !empty(_ALLFILES)
	@${ECHO}
	@${ECHO} '#'
	@location=`${PWD_CMD} | ${AWK} -F / '{ print $$(NF-1) "/" $$NF }'`; \
		${ECHO} '# Need additional files for ${PKGNAME} ('$$location')...'
.    for fetchfile in ${_ALLFILES}
.      if defined(_FETCH_MESSAGE)
	@(if [ ! -f ${_DISTDIR}/${fetchfile:T} ]; then			\
		${ECHO};						\
		filesize=`${AWK} '					\
			/^Size/ && $$2 == "(${fetchfile})" { print $$4 } \
			' ${DISTINFO_FILE}` || true;			\
		${ECHO} '# Prompt user to get ${fetchfile} ('$${filesize-???}' bytes) manually:'; \
		${ECHO} '#';						\
		${ECHO} ${_FETCH_MESSAGE:Q};				\
	fi)
.      elif defined(DYNAMIC_MASTER_SITES)
	@(if [ ! -f ${_DISTDIR}/${fetchfile:T} ]; then			\
		${ECHO};						\
		filesize=`${AWK} '					\
			/^Size/ && $$2 == "(${fetchfile})" { print $$4 } \
			' ${DISTINFO_FILE}` || true;			\
		${ECHO} '# Fetch ${fetchfile} ('$${filesize-???}' bytes):'; \
		${ECHO} '#';						\
		${ECHO} '${SH} -s ${fetchfile:T} <<"EOF" |(';		\
		${CAT} ${FILESDIR}/getsite.sh;				\
		${ECHO} EOF;						\
		${ECHO} read unsorted_sites;				\
		${ECHO} 'unsorted_sites="$${unsorted_sites} ${_MASTER_SITE_BACKUP}"'; \
		${ECHO} sites='"'${ORDERED_SITES:Q}'"';			\
		${ECHO} "${MKDIR} ${_DISTDIR}";				\
		${ECHO} 'cd ${_DISTDIR} && [ -f ${fetchfile} -o -f ${fetchfile:T} ] ||'; \
		${ECHO}	'for site in $$sites; do';			\
		${ECHO} '	${FETCH_CMD} ${FETCH_BEFORE_ARGS} "$${site}${fetchfile:T}" ${FETCH_AFTER_ARGS} && break ||'; \
		${ECHO} '	${ECHO} ${fetchfile:T} not fetched';	\
		${ECHO}	done;						\
		${ECHO} ')';						\
	fi)
.      else
	@(if [ ! -f ${_DISTDIR}/${fetchfile:T} ]; then			\
		${ECHO};						\
		filesize=`${AWK} '					\
			/^Size/ && $$2 == "(${fetchfile})" { print $$4 } \
			' ${DISTINFO_FILE}` || true;			\
		${ECHO} '# Fetch ${fetchfile} ('$${filesize-???}' bytes):'; \
		${ECHO} '#';						\
		${ECHO} 'unsorted_sites="${SITES.${fetchfile:T:S/=/--/}} ${_MASTER_SITE_BACKUP}"'; \
		${ECHO} sites='"'${ORDERED_SITES:Q}'"';			\
		${ECHO} "${MKDIR} ${_DISTDIR}";				\
		${ECHO} 'cd ${_DISTDIR} && [ -f ${fetchfile} -o -f ${fetchfile:T} ] ||'; \
		${ECHO}	'for site in $$sites; do';			\
		${ECHO} '	${FETCH_CMD} ${FETCH_BEFORE_ARGS} "$${site}${fetchfile:T}" ${FETCH_AFTER_ARGS} && break ||'; \
		${ECHO} '	${ECHO} ${fetchfile:T} not fetched';	\
		${ECHO}	done;						\
	fi)
.      endif # defined(_FETCH_MESSAGE) || defined(DYNAMIC_MASTER_SITES)
.    endfor
.  endif # !empty(_ALLFILES)
.endif # !target(fetch-list-one-pkg)

# Checksumming utilities

.PHONY: makesum
.if !target(makesum)
.  if defined(NO_CHECKSUM) && !empty(NO_CHECKSUM:M[Yy][Ee][Ss])
makesum:
	@${DO_NADA}
.  else
makesum: fetch uptodate-digest
	${_PKG_SILENT}${_PKG_DEBUG}					\
	newfile=${DISTINFO_FILE}.$$$$;					\
	if [ -f ${DISTINFO_FILE} ]; then				\
		${GREP} '^.NetBSD' ${DISTINFO_FILE} > $$newfile ||	\
			(${ECHO_N} "$$" > $$newfile &&			\
			 ${ECHO_N} "NetBSD" >> $$newfile && 		\
			 ${ECHO} "$$" >> $$newfile)			\
	else								\
		${ECHO_N} "$$" > $$newfile;				\
		${ECHO_N} "NetBSD" >> $$newfile; 			\
		${ECHO} "$$" >> $$newfile;				\
	fi;								\
	${ECHO} "" >> $$newfile;					\
	cd ${DISTDIR};							\
	for sumfile in "" ${_CKSUMFILES}; do				\
		if [ "X$$sumfile" = "X" ]; then continue; fi;		\
		for a in "" ${DIGEST_ALGORITHMS}; do			\
			if [ "X$$a" = "X" ]; then continue; fi;		\
			${DIGEST} $$a $$sumfile >> $$newfile;		\
		done;							\
		${WC} -c $$sumfile | ${AWK} '{ print "Size (" $$2 ") = " $$1 " bytes" }' >> $$newfile; \
	done;								\
	for ignore in "" ${_IGNOREFILES}; do				\
		if [ "X$$ignore" = "X" ]; then continue; fi;		\
		for a in "" ${DIGEST_ALGORITHMS}; do			\
			if [ "X$$a" = "X" ]; then continue; fi;		\
			${ECHO} "$$a ($$ignore) = IGNORE" >> $$newfile; \
		done;							\
	done;								\
	if [ -f ${DISTINFO_FILE} ]; then				\
		${AWK} '$$2 ~ /\(patch-[a-z0-9]+\)/ { print $$0 }' < ${DISTINFO_FILE} >> $$newfile; \
	fi;								\
	if ${CMP} -s $$newfile ${DISTINFO_FILE}; then			\
		${RM} -f $$newfile;					\
		${ECHO_MSG} "=> distinfo: distfiles part unchanged.";	\
	else								\
		${MV} $$newfile ${DISTINFO_FILE};			\
	fi
.  endif
.endif

.if !target(makepatchsum)
makepatchsum mps: uptodate-digest
	${_PKG_SILENT}${_PKG_DEBUG}					\
	newfile=${DISTINFO_FILE}.$$$$;					\
	if [ -f ${DISTINFO_FILE} ]; then				\
		${AWK} '$$2 !~ /\(patch-[a-z0-9]+\)/ { print $$0 }' < ${DISTINFO_FILE} >> $$newfile; \
	else \
		${ECHO} "\$$""NetBSD""\$$" > $$newfile;			\
		${ECHO} "" >> $$newfile;				\
	fi;								\
	if [ -d ${PATCHDIR} ]; then					\
		(cd ${PATCHDIR};					\
		for sumfile in "" patch-*; do				\
			case $$sumfile in				\
				"" | "patch-*") ;;			\
				patch-local-* | *.orig | *.rej | *~) ;;	\
				*)	${ECHO} "${PATCH_DIGEST_ALGORITHM} ($$sumfile) = `${SED} -e '/\$$NetBSD.*/d' $$sumfile | ${DIGEST} ${PATCH_DIGEST_ALGORITHM}`" >> $$newfile;; \
			esac;						\
		done);							\
	fi;								\
	if ${CMP} -s $$newfile ${DISTINFO_FILE}; then			\
		${RM} -f $$newfile;					\
		${ECHO_MSG} "=> distinfo: patches part unchanged.";	\
	else								\
		${MV} $$newfile ${DISTINFO_FILE};			\
	fi
.endif

# This target is done by invoking a sub-make so that DISTINFO_FILE gets
# re-evaluated after the "makepatchsum" target is made. This can be
# made into:
#makedistinfo mdi: makepatchsum makesum
# once a combined distinfo file exists for all packages
.if !target(makedistinfo)
makedistinfo mdi distinfo: makepatchsum
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} makesum
.endif

.PHONY: checksum
.if !target(checksum)
checksum: fetch uptodate-digest
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${DISTINFO_FILE} ]; then				\
		${ECHO_MSG} "=> No checksum file.";			\
	else								\
		(cd ${DISTDIR}; OK="true"; missing=""; 			\
		  for file in "" ${_CKSUMFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			filesummed=false;				\
			for a in ${DIGEST_ALGORITHMS}; do		\
				CKSUM2=`${AWK} 'NF == 4 && $$1 == "'$$a'" && $$2 == "('$$file')" && $$3 == "=" {print $$4; exit}' ${DISTINFO_FILE}`; \
				case "$${CKSUM2}" in			\
				"")	${ECHO_MSG} "=> No $$a checksum recorded for $$file."; \
					;;				\
				*)	filesummed=true;		\
					CKSUM=`${DIGEST} $$a < $$file`;	\
					if [ "$$CKSUM2" = "IGNORE" ]; then \
						${ECHO_MSG} "=> Checksum for $$file is set to IGNORE in checksum file even though"; \
						${ECHO_MSG} "   the file is not in the "'$$'"{IGNOREFILES} list."; \
						OK="false";		\
					elif [ "$$CKSUM" = "$$CKSUM2" ]; then	\
						${ECHO_MSG} "=> Checksum $$a OK for $$file."; \
					else				\
						${ECHO_MSG} "=> Checksum $$a mismatch for $$file."; \
						OK="false";		\
					fi ;;				\
				esac;					\
			done;						\
			case "$$filesummed" in				\
			false)	missing="$$missing $$file";		\
				OK=false ;;				\
			esac;						\
		  done;							\
		  for file in "" ${_IGNOREFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM2=`${AWK} 'NF == 4 && $$3 == "=" && $$2 == "('$$file')"{print $$4; exit}' ${DISTINFO_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} "=> No checksum recorded for $$file, file is in "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM2" != "IGNORE" ]; then		\
				${ECHO_MSG} "=> Checksum for $$file is not set to IGNORE in checksum file even though"; \
				${ECHO_MSG} "   the file is in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			fi;						\
		  done;							\
		  if [ "$$OK" != "true" ]; then				\
			case "$$missing" in				\
			"")	;;					\
			*)	${ECHO_MSG} "Missing checksums for $$missing";;	\
			esac;						\
			${ECHO_MSG} "Make sure the Makefile and checksum file (${DISTINFO_FILE})"; \
			${ECHO_MSG} "are up to date.  If you want to override this check, type"; \
			${ECHO_MSG} "\"${MAKE} NO_CHECKSUM=yes [other args]\"."; \
			exit 1;						\
		  fi) ;							\
	fi
.endif



# List of sites carrying binary pkgs. Variables "rel" and "arch" are
# replaced with OS release ("1.5", ...) and architecture ("mipsel", ...)
BINPKG_SITES?= \
	ftp://ftp.NetBSD.org/pub/NetBSD/packages/$${rel}/$${arch}

# List of flags to pass to pkg_add(1) for bin-install:

BIN_INSTALL_FLAGS?= 	# -v
.if ${PKG_INSTALLATION_TYPE} == "pkgviews"
PKG_ARGS_ADD=		-W ${LOCALBASE} -w ${DEFAULT_VIEW}
.endif
_BIN_INSTALL_FLAGS=	${BIN_INSTALL_FLAGS}
.if defined(_AUTOMATIC) && !empty(_AUTOMATIC:MYES)
_BIN_INSTALL_FLAGS+=	-A
.endif
_BIN_INSTALL_FLAGS+=	${PKG_ARGS_ADD}

_SHORT_UNAME_R=	${:!${UNAME} -r!:C@\.([0-9]*)[_.].*@.\1@} # n.n[_.]anything => n.n

# Install binary pkg, without strict uptodate-check first
.PHONY: su-bin-install
su-bin-install:
	@found="`${PKG_BEST_EXISTS} \"${PKGWILDCARD}\" || ${TRUE}`";	\
	if [ "$$found" != "" ]; then					\
		${ECHO_MSG} "${_PKGSRC_IN}> $$found is already installed - perhaps an older version?"; \
		${ECHO_MSG} "*** If so, you may wish to \`\`pkg_delete $$found'' and install"; \
		${ECHO_MSG} "*** this package again by \`\`${MAKE} bin-install'' to upgrade it properly."; \
		${SHCOMMENT} ${ECHO_MSG} "*** or use \`\`${MAKE} bin-update'' to upgrade it and all of its dependencies."; \
		exit 1;							\
	fi
	@rel=${_SHORT_UNAME_R:Q} ; \
	arch=${MACHINE_ARCH:Q} ; \
	pkgpath=${PKGREPOSITORY:Q} ; \
	for i in ${BINPKG_SITES} ; do pkgpath="$$pkgpath;$$i/All" ; done ; \
	${ECHO} "Trying $$pkgpath" ; 	\
	if ${SETENV} PKG_PATH="$$pkgpath" ${PKG_ADD} ${_BIN_INSTALL_FLAGS} ${PKGNAME_REQD:U${PKGNAME}:Q}${PKG_SUFX} ; then \
		${ECHO} "`${PKG_INFO} -e ${PKGNAME_REQD:U${PKGNAME}:Q}` successfully installed."; \
	else 				 			\
		${SHCOMMENT} Cycle through some FTP server here ;\
		${ECHO_MSG} "Installing from source" ;		\
		${MAKE} ${MAKEFLAGS} package 			\
			DEPENDS_TARGET=${DEPENDS_TARGET:Q} &&	\
		${MAKE} ${MAKEFLAGS} clean ;			\
	fi

.PHONY: bin-install
bin-install: su-target
	@${ECHO_MSG} "${_PKGSRC_IN}> Binary install for "${PKGNAME_REQD:U${PKGNAME}:Q}


################################################################
# The special package-building targets
# You probably won't need to touch these
################################################################

# Set to "html" by the README.html target to generate HTML code,
# or to "svr4" to print SVR4 (Solaris, ...) short package names, from
# SVR4_PKGNAME variable.
# This variable is passed down via build-depends-list and run-depends-list
PACKAGE_NAME_TYPE?=	name

_HTML_PKGNAME=		${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}
_HTML_PKGPATH=		${PKGPATH:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}
_HTML_PKGLINK=		<a href="../../${_HTML_PKGPATH}/README.html">${_HTML_PKGNAME}</a>

.PHONY: package-name
.if !target(package-name)
package-name:
.  if (${PACKAGE_NAME_TYPE} == "html")
	@${ECHO} ${_HTML_PKGLINK:Q}
.  elif (${PACKAGE_NAME_TYPE} == "svr4")
	@${ECHO} ${SVR4_PKGNAME}
.  else
	@${ECHO} ${PKGNAME}
.  endif # PACKAGE_NAME_TYPE
.endif # !target(package-name)

.PHONY: make-readme-html-help
.if !target(make-readme-html-help)
make-readme-html-help:
	@${ECHO} '${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}</a>: <TD>'${COMMENT:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g:Q}
.endif # !target(make-readme-html-help)

# Show (non-recursively) all the packages this package depends on.
# If PACKAGE_DEPENDS_WITH_PATTERNS is set, print as pattern (if possible)
PACKAGE_DEPENDS_WITH_PATTERNS?=true
.PHONY: run-depends-list
.if !target(run-depends-list)
run-depends-list:
.  for dep in ${DEPENDS}
	@pkg="${dep:C/:.*//}";						\
	dir="${dep:C/[^:]*://}";					\
	cd ${.CURDIR};							\
	if ${PACKAGE_DEPENDS_WITH_PATTERNS}; then			\
		${ECHO} "$$pkg";					\
	else								\
		if cd $$dir 2>/dev/null; then				\
			${MAKE} ${MAKEFLAGS} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}; \
		else 							\
			${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
		fi;							\
	fi
.  endfor
.endif # target(run-depends-list)

.PHONY: build-depends-list
.if !target(build-depends-list)
build-depends-list:
	@for dir in `${MAKE} ${MAKEFLAGS} show-all-depends-dirs-excl`;	\
	do								\
		(cd ../../$$dir &&					\
		${MAKE} ${MAKEFLAGS} package-name)			\
	done
.endif

# If PACKAGES is set to the default (../../pkgsrc/packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.PHONY: binpkg-list
.if !target(binpkg-list)
binpkg-list:
	@if ${TEST} -d ${PACKAGES}; then					\
		cd ${PACKAGES};						\
		case ${.CURDIR} in					\
		*/pkgsrc/packages)					\
			for pkg in ${PKGREPOSITORYSUBDIR}/${PKGWILDCARD}${PKG_SUFX} ; \
			do 						\
				if [ -f "$$pkg" ] ; then		\
					pkgname=`${ECHO} $$pkg | ${SED} 's@.*/@@'`; \
					${ECHO} "<TR><TD>${MACHINE_ARCH}:<TD><a href=\"${PKG_URL}/$$pkg\">$$pkgname</a><TD>(${OPSYS} ${OS_VERSION})"; \
				fi ;					\
			done ; 						\
			;;						\
		*)							\
			cd ${PACKAGES}/../..;				\
			for i in [1-9].*/*; do  			\
				if cd ${PACKAGES}/../../$$i/${PKGREPOSITORYSUBDIR} 2>/dev/null; then \
					for j in ${PKGWILDCARD}${PKG_SUFX}; \
					do 				\
						if [ -f "$$j" ]; then	\
							${ECHO} $$i/$$j;\
						fi;			\
					done; 				\
				fi; 					\
			done | ${AWK} -F/ '				\
				{					\
					release = $$1;			\
					arch = $$2; 			\
					pkg = $$3;			\
					gsub("\\.tgz","", pkg);		\
					if (arch != "m68k" && arch != "mipsel") { \
						if (arch in urls)	\
							urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a>, " urls[arch]; \
						else			\
							urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a> "; \
					}				\
				} 					\
				END { 					\
					for (av in urls) {		\
						split(av, ava, "/");	\
						arch=ava[1];		\
						pkg=ava[2];		\
						release=ava[3];		\
						print "<TR><TD>" arch ":<TD>" urls[av] "<TD>(${OPSYS} " release ")"; \
					}				\
				}' | ${SORT}				\
			;;						\
		esac;							\
	fi
.endif

################################################################
# Everything after here are internal targets and really
# shouldn't be touched by anybody but the release engineers.
################################################################

# This target generates an index entry suitable for aggregation into
# a large index.  Format is:
#
# distribution-name|package-path|installation-prefix|comment| \
#  description-file|maintainer|categories|build deps|run deps|for arch| \
#  not for opsys
#
.PHONY: describe
.if !target(describe)
describe:
	@${ECHO_N} "${PKGNAME}|${.CURDIR}|";				\
	${ECHO_N} "${PREFIX}|";						\
	${ECHO_N} ${COMMENT:Q};						\
	if [ -f ${DESCR_SRC} ]; then					\
		${ECHO_N} "|${DESCR_SRC}";				\
	else								\
		${ECHO_N} "|/dev/null";					\
	fi;								\
	${ECHO_N} "|${MAINTAINER}|${CATEGORIES}|";			\
	case "A${BUILD_DEPENDS}B${DEPENDS}C" in	\
		ABC) ;;							\
		*) cd ${.CURDIR} && ${ECHO_N} `${MAKE} ${MAKEFLAGS} build-depends-list | ${SORT} -u`;; \
	esac;								\
	${ECHO_N} "|";							\
	if [ "${DEPENDS}" != "" ]; then					\
		cd ${.CURDIR} && ${ECHO_N} `${MAKE} ${MAKEFLAGS} run-depends-list | ${SORT} -u`; \
	fi;								\
	${ECHO_N} "|";							\
	if [ "${ONLY_FOR_PLATFORM}" = "" ]; then			\
		${ECHO_N} "any";					\
	else								\
		${ECHO_N} "${ONLY_FOR_PLATFORM}";			\
	fi;								\
	${ECHO_N} "|";							\
	if [ "${NOT_FOR_PLATFORM}" = "" ]; then				\
		${ECHO_N} "any";					\
	else								\
		${ECHO_N} "not ${NOT_FOR_PLATFORM}";			\
	fi;								\
	${ECHO} ""
.endif

.PHONY: readmes
.if !target(readmes)
readmes:	readme
.endif

# This target is used to generate README.html files
.PHONY: readme
.if !target(readme)
FTP_PKG_URL_HOST?=	ftp://ftp.NetBSD.org
FTP_PKG_URL_DIR?=	/pub/NetBSD/packages

readme:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} README.html PKG_URL=${FTP_PKG_URL_HOST}${FTP_PKG_URL_DIR}
.endif

# This target is used to generate README.html files, very like "readme"
# However, a different target was used for ease of use.
.PHONY: cdrom-readme
.if !target(cdrom-readme)
CDROM_PKG_URL_HOST?=	file://localhost
CDROM_PKG_URL_DIR?=	/usr/pkgsrc/packages

cdrom-readme:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} README.html PKG_URL=${CDROM_PKG_URL_HOST}${CDROM_PKG_URL_DIR}
.endif

README_NAME=	${TEMPLATES}/README.pkg

# set up the correct license information as a sed expression
.if defined(LICENSE)
SED_LICENSE_EXPR=	-e 's|%%LICENSE%%|<p>Please note that this package has a ${LICENSE} license.</p>|'
.else
SED_LICENSE_EXPR=	-e 's|%%LICENSE%%||'
.endif

# set up the "more info URL" information as a sed expression
.if defined(HOMEPAGE)
SED_HOMEPAGE_EXPR=	-e 's|%%HOMEPAGE%%|<p>This package has a home page at <a HREF="${HOMEPAGE}">${HOMEPAGE}</a>.</p>|'
.else
SED_HOMEPAGE_EXPR=	-e 's|%%HOMEPAGE%%||'
.endif

.PHONY: show-vulnerabilities-html
show-vulnerabilities-html:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${PKGVULNDIR}/pkg-vulnerabilities ]; then		\
		${AWK} '/^${PKGBASE}[-<>=]+[0-9]/ { gsub("\<", "\\&lt;", $$1);	\
			 gsub("\>", "\\&gt;", $$1);			\
			 printf("<LI><STRONG>%s has a %s exploit (see <a href=\"%s\">%s</a> for more details)</STRONG></LI>\n", $$1, $$2, $$3, $$3) }' \
			${PKGVULNDIR}/pkg-vulnerabilities;		\
	fi


# If PACKAGES is set to the default (../../packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.PHONY: README.html
README.html: .PRECIOUS
	@${SETENV} AWK=${AWK} BMAKE=${MAKE} ../../mk/scripts/mkdatabase -f $@.tmp1
	@if ${TEST} -d ${PACKAGES}; then					\
		cd ${PACKAGES};						\
		case `${PWD_CMD}` in					\
			${PKGSRCDIR}/packages)				\
				MULTIARCH=no;				\
				;;					\
			*)						\
				MULTIARCH=yes;				\
				;;					\
		esac;							\
		cd ${.CURDIR} ;						\
	fi;								\
	${AWK} -f ../../mk/scripts/genreadme.awk \
		builddependsfile=/dev/null \
		dependsfile=/dev/null \
		AWK=${AWK:Q} \
		CMP=${CMP:Q} \
		DISTDIR=${DISTDIR:Q} \
		GREP=${GREP:Q} \
		PACKAGES=${PACKAGES:Q} \
		PKG_INFO=${PKG_INFO:Q} \
		PKG_SUFX=${PKG_SUFX:Q} \
		PKG_URL=${PKG_URL:Q} \
		PKGSRCDIR=${.CURDIR:C|/[^/]*/[^/]*$||:Q} \
		SED=${SED:Q} \
		SETENV=${SETENV:Q} \
		SORT=${SORT:Q} \
		TMPDIR=${TMPDIR:U/tmp:Q} \
		SINGLEPKG=${PKGPATH:Q} \
		$@.tmp1
	@${RM} $@.tmp1

.PHONY: show-pkgtools-version
.if !target(show-pkgtools-version)
show-pkgtools-version:
	@${ECHO} ${PKGTOOLS_VERSION}
.endif

# convenience target, to display make variables from command line
# i.e. "make show-var VARNAME=var", will print var's value
.PHONY: show-var
show-var:
	@${ECHO} ${${VARNAME}:Q}

# enhanced version of target above, to display multiple variables
.PHONY: show-vars
show-vars:
.for VARNAME in ${VARNAMES}
	@${ECHO} ${${VARNAME}:Q}
.endfor

# displays multiple variables as shell expressions
# VARS is space separated list of VARNAME:shellvarname
.PHONY: show-vars-eval
show-vars-eval:
.for var in ${VARS}
	@${ECHO} ${var:C/^.*://}="${${var:C/:.*$//}:Q}"
.endfor

.PHONY: print-build-depends-list
.if !target(print-build-depends-list)
print-build-depends-list:
.  if !empty(BUILD_DEPENDS) || !empty(DEPENDS)
	@${ECHO_N} 'This package requires package(s) "'
	@${ECHO_N} `${MAKE} ${MAKEFLAGS} build-depends-list | ${SORT} -u`
	@${ECHO} '" to build.'
.  endif
.endif

.PHONY: print-run-depends-list
.if !target(print-run-depends-list)
print-run-depends-list:
.  if !empty(DEPENDS)
	@${ECHO_N} 'This package requires package(s) "'
	@${ECHO_N} `${MAKE} ${MAKEFLAGS} run-depends-list | ${SORT} -u`
	@${ECHO} '" to run.'
.  endif
.endif

# This target is used by the mk/scripts/mkreadme script to generate
# README.html files
.PHONY: print-summary-data
.if !target(print-summary-data)
print-summary-data:
	@${ECHO} depends ${PKGPATH} ${DEPENDS:Q}
	@${ECHO} build_depends ${PKGPATH} ${BUILD_DEPENDS:Q}
	@${ECHO} conflicts ${PKGPATH} ${CONFLICTS:Q}
	@${ECHO} index ${PKGPATH} ${PKGNAME:Q}
	@${ECHO} htmlname ${PKGPATH} ${_HTML_PKGLINK:Q}
	@${ECHO} homepage ${PKGPATH} ${HOMEPAGE:Q}
	@${ECHO} wildcard ${PKGPATH} ${PKGWILDCARD:Q}
	@${ECHO} comment ${PKGPATH} ${COMMENT:Q}
	@${ECHO} license ${PKGPATH} ${LICENSE:Q}
	@if [ "${ONLY_FOR_PLATFORM}" = "" ]; then			\
		${ECHO} "onlyfor ${PKGPATH} any";			\
	else								\
		${ECHO} "onlyfor ${PKGPATH} ${ONLY_FOR_PLATFORM}";	\
	fi
	@if [ "${NOT_FOR_PLATFORM}" = "" ]; then			\
		${ECHO} "notfor ${PKGPATH} any";			\
	else								\
		${ECHO} "notfor ${PKGPATH} not ${NOT_FOR_PLATFORM}";	\
	fi;
	@${ECHO} "maintainer ${PKGPATH} ${MAINTAINER}"
	@${ECHO} "categories ${PKGPATH} ${CATEGORIES}"
	@if [ -f ${DESCR_SRC} ]; then					\
		${ECHO}  "descr ${PKGPATH} ${DESCR_SRC:S;${PKGSRCDIR}/;;g}"; \
	else								\
		${ECHO}  "descr ${PKGPATH} /dev/null";			\
	fi
	@${ECHO} "prefix ${PKGPATH} ${PREFIX}"
.endif

LICENSE_FILE?=		${PKGSRCDIR}/licenses/${LICENSE}

.if !target(show-license)
show-license show-licence:
	@license=${LICENSE:Q};						\
	license_file=${LICENSE_FILE:Q};					\
	pager=${PAGER:Q};						\
	case "$$pager" in "") pager=${CAT:Q};; esac;			\
	case "$$license" in "") exit 0;; esac;				\
	if ${TEST} -f "$$license_file"; then				\
		$$pager "$$license_file";				\
	else								\
		${ECHO} "Generic $$license information not available";	\
		${ECHO} "See the package description (pkg_info -d ${PKGNAME}) for more information."; \
	fi
.endif

# This target is defined in bsd.options.mk for packages that use
# the options framework.
.if !target(show-options)
.PHONY: show-options
show-options:
	@${ECHO} This package does not use the options framework.
.endif

# Depend is generally meaningless for arbitrary packages, but if someone wants
# one they can override this.  This is just to catch people who've gotten into
# the habit of typing `${MAKE} depend all install' as a matter of course.
#
.PHONY: depend
.if !target(depend)
depend:
.endif

# Same goes for tags
.PHONY: tags
.if !target(tags)
tags:
.endif

.include "../../mk/plist/bsd.plist.mk"

.include "../../mk/bsd.utils.mk"

.include "../../mk/subst.mk"

#
# For bulk build targets (bulk-install, bulk-package), the
# BATCH variable must be set in /etc/mk.conf:
#
.if defined(BATCH)
.  include "../../mk/bulk/bsd.bulk-pkg.mk"
.endif

# Create a PKG_ERROR_HANDLER shell command for each class listed in
# PKG_ERROR_CLASSES.  The error handler is meant to be invoked within
# a make target.
#
.for _class_ in ${PKG_ERROR_CLASSES}
PKG_ERROR_HANDLER.${_class_}?=	{					\
		ec=$$?;							\
		for str in ${PKG_ERROR_MSG.${_class_}}; do		\
			${ECHO} "${_PKGSRC_IN}> $$str";			\
		done;							\
		exit $$ec;						\
	}
.endfor

# Cache variables listed in MAKEVARS in a phase-specific "makevars.mk"
# file.  These variables are effectively passed to sub-make processes
# that are invoked on the same Makefile.
#
.for _phase_ in ${ALL_PHASES}
${_MAKEVARS_MK.${_phase_}}: ${WRKDIR}
.  if !empty(PKG_PHASE:M${_phase_})
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET}.tmp
.    for _var_ in ${MAKEVARS:O:u}
.      if defined(${_var_})
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO} ${_var_}"=	"${${_var_}:Q} >> ${.TARGET}.tmp
.      endif
.    endfor
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} -f ${.TARGET}.tmp; then				\
		( ${ECHO} ".if !defined(_MAKEVARS_MK)";			\
		  ${ECHO} "_MAKEVARS_MK=	defined";		\
		  ${ECHO} "";						\
		  ${CAT} ${.TARGET}.tmp;				\
		  ${ECHO} "";						\
		  ${ECHO} ".endif # _MAKEVARS_MK";			\
		) > ${.TARGET};						\
		${RM} -f ${.TARGET}.tmp;				\
	fi
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${.TARGET}
.endfor
.undef _phase_

# show-tools emits a /bin/sh shell script that defines all known tools
# to the values they have in the pkgsrc infrastructure.
#
# Don't move this code away from here unless you know what you're doing.
#
.PHONY: show-tools
show-tools:
.for _t_ in ${_USE_TOOLS}
.  if defined(_TOOLS_VARNAME.${_t_})
	@${ECHO} ${_TOOLS_VARNAME.${_t_}:Q}=${${_TOOLS_VARNAME.${_t_}}:Q:Q}
.  endif
.endfor

# changes-entry appends a correctly-formatted entry to the pkgsrc
# CHANGES file.
#
# The following variables may be set:
#
#    CTYPE is the type of entry to add and is one of "Added", "Updated",
#	"Renamed", "Moved", of "Removed".  The default CTYPE is "Updated".
#
#    NETBSD_LOGIN_NAME is the login name assigned by the NetBSD Project.
#	It defaults to the local login name.
#
#    PKGSRC_CHANGES is the path to the CHANGES file to which the entry
#	is appended.  It defaults to ${PKGSRCDIR}/doc/CHANGES.
#
# Example usage:
#
#	% cd /usr/pkgsrc/category/package
#	% make changes-entry CTYPE=Added
#
CTYPE?=			Updated
NETBSD_LOGIN_NAME?=	${_NETBSD_LOGIN_NAME_cmd:sh}
PKGSRC_CHANGES?=	${PKGSRCDIR}/doc/CHANGES-${_CYEAR_cmd:sh}

_CYEAR_cmd=		${DATE} -u +%Y
_CDATE_cmd=		${DATE} -u +%Y-%m-%d
_NETBSD_LOGIN_NAME_cmd=	${ID} -nu

_CTYPE1=	"	"${CTYPE:Q}" "${PKGPATH:Q}
.if !empty(CTYPE:MUpdated)
_CTYPE2=	" to "${PKGVERSION:Q}
.elif !empty(CTYPE:MAdded)
_CTYPE2=	" version "${PKGVERSION:Q}
.elif !empty(CTYPE:MRenamed) || !empty(CTYPE:MMoved)
_CTYPE2=	" to XXX"
.else
_CTYPE2=
.endif
_CTYPE3=	" ["${NETBSD_LOGIN_NAME:Q}" "${_CDATE_cmd:sh:Q}"]"

.PHONY: changes-entry
changes-entry:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO} ${_CTYPE1}${_CTYPE2}${_CTYPE3} >> ${PKGSRC_CHANGES:Q}
