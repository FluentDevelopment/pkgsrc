#	$NetBSD: bsd.pkg.mk,v 1.1862 2006/07/06 16:58:17 jlam Exp $
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

.MAIN: all

.include "../../mk/bsd.prefs.mk"

.include "${PKGSRCDIR}/mk/flavor/bsd.flavor-vars.mk"
.include "${PKGSRCDIR}/mk/check/bsd.check-vars.mk"
.include "${PKGSRCDIR}/mk/depends/bsd.depends-vars.mk"
.include "${PKGSRCDIR}/mk/fetch/bsd.fetch-vars.mk"
.include "${PKGSRCDIR}/mk/extract/bsd.extract-vars.mk"
.include "${PKGSRCDIR}/mk/patch/bsd.patch-vars.mk"
.include "${PKGSRCDIR}/mk/configure/bsd.configure-vars.mk"
.include "${PKGSRCDIR}/mk/build/bsd.build-vars.mk"
.include "${PKGSRCDIR}/mk/install/bsd.install-vars.mk"
.include "${PKGSRCDIR}/mk/bsd.pkg.error.mk"

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

BUILD_DEPENDS?=		# empty
COMMENT?=		(no description)
DEPENDS?=		# empty
DESCR_SRC?=		${PKGDIR}/DESCR
DIGEST_ALGORITHMS?=	SHA1 RMD160
DISTINFO_FILE?=		${PKGDIR}/distinfo
INTERACTIVE_STAGE?=	none
MAINTAINER?=		pkgsrc-users@NetBSD.org
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
PKG_FAIL_REASON+='The package tools installed on this system are out of date.'
PKG_FAIL_REASON+='The installed package tools are dated ${PKGTOOLS_VERSION:C|(....)(..)(..)|\1/\2/\3|} and you must'
PKG_FAIL_REASON+='update them to at least ${PKGTOOLS_REQD:C|(....)(..)(..)|\1/\2/\3|} using the following command:'
PKG_FAIL_REASON+=''
PKG_FAIL_REASON+='    (cd ${PKGSRCDIR}/pkgtools/pkg_install && ${MAKE} clean && ${MAKE} update)'
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

# Store the result in the +BUILD_INFO file so we can query for the build
# options using "pkg_info -Q PKG_OPTIONS <pkg>".
#
.if defined(PKG_SUPPORTED_OPTIONS) && defined(PKG_OPTIONS)
BUILD_DEFS+=            PKG_OPTIONS
.endif

.if empty(DEPOT_SUBDIR)
PKG_FAIL_REASON+=	"DEPOT_SUBDIR may not be empty."
.endif

# ZERO_FILESIZE_P exits with a successful return code if the given file
#	has zero length.
# NONZERO_FILESIZE_P exits with a successful return code if the given file
#	has nonzero length.
#
_ZERO_FILESIZE_P=	${AWK} 'END { exit (NR > 0) ? 1 : 0; }'
_NONZERO_FILESIZE_P=	${AWK} 'END { exit (NR > 0) ? 0 : 1; }'

# Automatically increase process limit where necessary for building.
_ULIMIT_CMD=		${UNLIMIT_RESOURCES:@_lim_@${ULIMIT_CMD_${_lim_}};@}

_INTERACTIVE_COOKIE=	${.CURDIR}/.interactive_stage
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

# OVERRIDE_DIRDEPTH represents the common directory depth under
#	${WRKSRC} up to which we find the files that need to be
#	overridden.  By default, we search two levels down, i.e.,
#	*/*/file.
#
OVERRIDE_DIRDEPTH?=	2

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

WARNING_CAT?=		${SED} -e "s|^|WARNING: |" 1>&2
ERROR_CAT?=		${SED} -e "s|^|ERROR: |" 1>&2

# How to do nothing.  Override if you, for some strange reason, would rather
# do something.
DO_NADA?=		${TRUE}

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

# Tools
.include "../../mk/tools/bsd.tools.mk"

# Barrier
.include "../../mk/bsd.pkg.barrier.mk"

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
.      if defined(PKG_FAIL_REASON) && !empty(PKG_FAIL_REASON:M*)
	@for str in ${PKG_FAIL_REASON}; do				\
		${ERROR_MSG} "$$str";					\
	done
.      endif
.      if defined(PKG_SKIP_REASON) && !empty(PKG_SKIP_REASON:M*)
	@${WARNING_MSG} "Skipping ${PKGNAME}:";				\
	for str in ${PKG_SKIP_REASON}; do				\
		${WARNING_MSG} "$$str";					\
	done
.      endif
.    endif
.    if defined(PKG_FAIL_REASON) && !empty(PKG_FAIL_REASON:M*)
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

################################################################
# More standard targets start here.
#
# These are the body of the build/install framework.  If you are
# not happy with the default actions, and you can't solve it by
# adding pre-* or post-* targets/scripts, override these.
################################################################

# acquire-lock, release-lock are .USE macro targets for acquiring and
# release coarse-grained locks.
#
_LOCKFILE=	${WRKDIR}/.lockfile

acquire-lock: .USE
.if ${PKGSRC_LOCKTYPE} == "none"
	@${DO_NADA}
.else
	@if ${TEST} ! -x ${SHLOCK:Q}""; then				\
		${ERROR_MSG} "The ${SHLOCK:Q} utility does not exist, and is necessary for locking."; \
		${ERROR_MSG} "Please \""${MAKE:Q}" install\" in ../../pkgtools/shlock."; \
		exit 1;							\
	fi
.  if !defined(OBJHOSTNAME)
	@${ERROR_MSG} "PKGSRC_LOCKTYPE needs OBJHOSTNAME defined.";	\
	exit 1
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}set -e;				\
	ppid=`${PS} -p $$$$ -o ppid | ${AWK} 'NR == 2 { print $$1 }'`;	\
	if ${TEST} -z "$$ppid"; then					\
		${ERROR_MSG} "No parent process ID found.";		\
		exit 1;							\
	fi;								\
	while ${TRUE}; do						\
		if ${TEST} -f /var/run/dmesg.boot -a -f ${_LOCKFILE}; then \
			rebooted=`${FIND} /var/run/dmesg.boot -newer ${_LOCKFILE} -print`; \
			if ${TEST} -n "$$rebooted"; then		\
				${STEP_MSG} "Removing stale ${_LOCKFILE}"; \
				${RM} -f ${_LOCKFILE};			\
			fi;						\
		fi;							\
		${MKDIR} ${_LOCKFILE:H};				\
		if ${SHLOCK} -f ${_LOCKFILE} -p $$ppid; then		\
			break;						\
		fi;							\
		case ${PKGSRC_LOCKTYPE:Q}"" in				\
		once)	${ERROR_MSG} "Lock is held by pid `${CAT} ${_LOCKFILE}`"; \
			exit 1;						\
			;;						\
		sleep)	${STEP_MSG} "Lock is held by pid `${CAT} ${_LOCKFILE}`"; \
			${SLEEP} ${PKGSRC_SLEEPSECS};			\
			;;						\
		esac;							\
	done
.  if defined(PKG_VERBOSE)
	@${STEP_MSG} "Lock acquired for ${.TARGET:S/^acquire-//:S/-lock$//} on behalf of process `${CAT} ${_LOCKFILE}`"
.  endif
.endif

release-lock: .USE
.if ${PKGSRC_LOCKTYPE} == "none"
	@${DO_NADA}
.else
.  if defined(PKG_VERBOSE)
	@${STEP_MSG} "Lock released for ${.TARGET:S/^release-//:S/-lock$//} on behalf of process `${CAT} ${_LOCKFILE}`"
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${_LOCKFILE}
.endif

.PHONY: makedirs
makedirs: ${WRKDIR}

${WRKDIR}:
.if !defined(KEEP_WRKDIR)
.  if ${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} -f ${_LOCKFILE} || ${RM} -fr ${WRKDIR}
.  endif
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${WRKDIR}

# Create a symlink from ${WRKDIR} to the package directory if
# CREATE_WRKDIR_SYMLINK is "yes".
#
CREATE_WRKDIR_SYMLINK?=	yes

.if defined(WRKOBJDIR) && !empty(CREATE_WRKDIR_SYMLINK:M[Yy][Ee][Ss])
makedirs: ${.CURDIR}/${WRKDIR_BASENAME}
 ${.CURDIR}/${WRKDIR_BASENAME}:
.  if ${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} -f ${_LOCKFILE} || ${RM} -f ${.TARGET}
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${LN} -s ${WRKDIR} ${.TARGET} 2>/dev/null; then		\
		${ECHO} "${.TARGET:T} -> ${WRKDIR}";			\
	fi
.endif

.include "${PKGSRCDIR}/mk/flavor/bsd.flavor.mk"

# Dependencies
.include "${PKGSRCDIR}/mk/depends/bsd.depends.mk"

# Check
.include "${PKGSRCDIR}/mk/check/bsd.check.mk"

# Clean
.include "../../mk/bsd.pkg.clean.mk"

# Fetch
.include "${PKGSRCDIR}/mk/fetch/bsd.fetch.mk"

# Extract
.include "${PKGSRCDIR}/mk/extract/bsd.extract.mk"

# Patch
.include "${PKGSRCDIR}/mk/patch/bsd.patch.mk"

# Configure
.include "${PKGSRCDIR}/mk/configure/bsd.configure.mk"

# Build
.include "${PKGSRCDIR}/mk/build/bsd.build.mk"

# Install
.include "${PKGSRCDIR}/mk/install/bsd.install.mk"

# Package
.include "${PKGSRCDIR}/mk/package/bsd.package.mk"

.include "${PKGSRCDIR}/mk/bsd.pkg.update.mk"

################################################################
# Skeleton targets start here
#
# You shouldn't have to change these.  Either add the pre-* or
# post-* targets/scripts or redefine the do-* targets.  These
# targets don't do anything other than checking for cookies and
# call the necessary targets/scripts.
################################################################

# su-target is a macro target that does just-in-time su-to-root before
# reinvoking the make process as root.  It acquires root privileges and
# invokes a new make process with the target named "su-${.TARGET}".
#
_ROOT_CMD=	cd ${.CURDIR} &&					\
		${SETENV} PATH="$${PATH}:"${SU_CMD_PATH_APPEND:Q}	\
		${MAKE} ${MAKEFLAGS}					\
			PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL:Q}		\
			su-${.TARGET} ${MAKEFLAGS.${.TARGET}}

.PHONY: su-target
su-target: .USE
	${_PKG_SILENT}${_PKG_DEBUG}set -e;				\
	case ${PRE_CMD.su-${.TARGET}:Q}"" in				\
	"")	;;							\
	*)	${PRE_CMD.su-${.TARGET}} ;;				\
	esac;								\
	if ${TEST} `${ID} -u` = `${ID} -u ${ROOT_USER}`; then		\
		${_ROOT_CMD};						\
	else								\
		case ${PRE_ROOT_CMD:Q}"" in				\
		${TRUE:Q}"")	;;					\
		*) ${WARNING_MSG} "Running: "${PRE_ROOT_CMD:Q} ;;	\
		esac;							\
		${PRE_ROOT_CMD};					\
		${STEP_MSG} "Becoming \`\`${ROOT_USER}'' to make su-${.TARGET} (`${ECHO} ${SU_CMD} | ${AWK} '{ print $$1 }'`)"; \
		${SU_CMD} ${_ROOT_CMD:Q};				\
		${STEP_MSG} "Dropping \`\`${ROOT_USER}'' privileges.";	\
	fi

################################################################
# Some more targets supplied for users' convenience
################################################################

# Run pkglint:
.PHONY: lint
lint:
	${_PKG_SILENT}${_PKG_DEBUG}${LOCALBASE}/bin/pkglint


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
		${ERROR_MSG} "$$found is already installed - perhaps an older version?"; \
		${ERROR_MSG} "If so, you may wish to \`\`pkg_delete $$found'' and install"; \
		${ERROR_MSG} "this package again by \`\`${MAKE} bin-install'' to upgrade it properly."; \
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
	@${PHASE_MSG} "Binary install for "${PKGNAME_REQD:U${PKGNAME}:Q}


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
			${PHASE_MSG} "$$str";				\
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
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET}.tmp
.  for _var_ in ${MAKEVARS:O:u}
.    if defined(${_var_})
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO} ${_var_}"=	"${${_var_}:Q} >> ${.TARGET}.tmp
.    endif
.  endfor
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
