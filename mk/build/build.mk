# $NetBSD: build.mk,v 1.1 2006/07/05 06:09:15 jlam Exp $
#
# BUILD_MAKE_FLAGS is the list of arguments that is passed to the make
#	process.
#
# BUILD_TARGET is the target from ${MAKEFILE} that should be invoked
#	to build the sources.
#
BUILD_MAKE_FLAGS?=	${MAKE_FLAGS}
BUILD_TARGET?=		all

######################################################################
### build (PUBLIC)
######################################################################
### build is a public target to build the sources from the package.
###
_BUILD_TARGETS+=	configure
_BUILD_TARGETS+=	acquire-build-lock
_BUILD_TARGETS+=	${_BUILD_COOKIE}
_BUILD_TARGETS+=	release-build-lock
_BUILD_TARGETS+=	pkginstall

.PHONY: build
.if !target(build)
build: ${_BUILD_TARGETS}
.endif

.PHONY: acquire-build-lock release-build-lock
acquire-build-lock: acquire-lock
release-build-lock: release-lock

.if !exists(${_BUILD_COOKIE})
${_BUILD_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${BUILD_ENV} ${MAKE} ${MAKEFLAGS} real-build PKG_PHASE=build || ${PKG_ERROR_HANDLER.build}
.else
${_BUILD_COOKIE}:
	@${DO_NADA}
.endif

PKG_ERROR_CLASSES+=	build
PKG_ERROR_MSG.build=							\
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

######################################################################
### real-build (PRIVATE)
######################################################################
### real-build is a helper target onto which one can hook all of the
### targets that do the actual building of the sources.
###
_REAL_BUILD_TARGETS+=	build-check-interactive
_REAL_BUILD_TARGETS+=	build-message
_REAL_BUILD_TARGETS+=	build-vars
_REAL_BUILD_TARGETS+=	pre-build
_REAL_BUILD_TARGETS+=	do-build
_REAL_BUILD_TARGETS+=	post-build
_REAL_BUILD_TARGETS+=	build-cookie
_REAL_BUILD_TARGETS+=	error-check

.PHONY: real-build
real-build: ${_REAL_BUILD_TARGETS}

.PHONY: build-message
build-message:
	@${PHASE_MSG} "Building for ${PKGNAME}"

######################################################################
### build-check-interactive (PRIVATE)
######################################################################
### build-check-interactive checks whether we must do an interactive
### build or not.
###
build-check-interactive:
.if !empty(INTERACTIVE_STAGE:Mbuild) && defined(BATCH)
	@${ERROR_MSG} "The build stage of this package requires user interaction"
	@${ERROR_MSG} "Please build manually with:"
	@${ERROR_MSG} "    \"cd ${.CURDIR} && ${MAKE} build\""
	@${TOUCH} ${_INTERACTIVE_COOKIE}
	@${FALSE}
.else
	@${DO_NADA}
.endif

######################################################################
### pre-build, do-build, post-build (PUBLIC, override)
######################################################################
### {pre,do,post}-build are the heart of the package-customizable
### build targets, and may be overridden within a package Makefile.
###
.PHONY: pre-build do-build post-build

.if !target(do-build)
do-build:
.  for _dir_ in ${BUILD_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}			\
	cd ${WRKSRC} && cd ${_dir_} &&					\
	${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${BUILD_MAKE_FLAGS}	\
		-f ${MAKEFILE} ${BUILD_TARGET}
.  endfor
.endif

.if !target(pre-build)
pre-build:
	@${DO_NADA}
.endif

.if !target(post-build)
post-build:
	@${DO_NADA}
.endif
