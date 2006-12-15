# $NetBSD: test.mk,v 1.9 2006/12/15 12:46:23 martti Exp $
#
# Package-settable variables:
#
# TEST_DIRS is the list of directories in which to perform the build
#	process.  If the directories are relative paths, then they
#	are assumed to be relative to ${WRKSRC}.
#
# TEST_ENV is the shell environment that is exported to the make
#       process.
#
# TEST_MAKE_FLAGS is the list of arguments that is passed to the make
#	process, in addition to the usual MAKE_FLAGS.
#
# Variables defined by this file:
#
# TEST_MAKE_CMD
#	This command sets the proper environment for the test phase
#	and runs make(1) on it. It takes a list of make targets and
#	flags as argument.
#
# See also:
#	mk/build/build.mk
#

TEST_DIRS?=		${BUILD_DIRS}
TEST_ENV+=		${MAKE_ENV}
TEST_MAKE_FLAGS?=	# none

TEST_MAKE_CMD= \
	${SETENV} ${MAKE_ENV}						\
		${MAKE_PROGRAM} ${MAKE_FLAGS} ${TEST_MAKE_FLAGS}	\
			-f ${MAKE_FILE}

######################################################################
### test (PUBLIC)
######################################################################
### build is a public target to build the sources from the package.
###
_TEST_TARGETS+=	check-vulnerable
_TEST_TARGETS+=	build
_TEST_TARGETS+=	acquire-test-lock
_TEST_TARGETS+=	${_COOKIE.test}
_TEST_TARGETS+=	release-test-lock

.PHONY: test
.if !target(test)
.  if exists(${_COOKIE.test})
test:
	@${DO_NADA}
.  elif defined(_PKGSRC_BARRIER)
test: ${_TEST_TARGETS}
.  else
test: barrier
.  endif
.endif

.PHONY: acquire-test-lock release-test-lock
acquire-test-lock: acquire-lock
release-test-lock: release-lock

.if exists(${_COOKIE.test})
${_COOKIE.test}:
	@${DO_NADA}
.else
${_COOKIE.test}: real-test
.endif

######################################################################
### real-test (PRIVATE)
######################################################################
### real-test is a helper target onto which one can hook all of the
### targets that do the actual test of the built objects.
###
_REAL_TEST_TARGETS+=	test-check-interactive
_REAL_TEST_TARGETS+=	test-message
_REAL_TEST_TARGETS+=	pre-test
_REAL_TEST_TARGETS+=	do-test
_REAL_TEST_TARGETS+=	post-test
_REAL_TEST_TARGETS+=	test-cookie
_REAL_TEST_TARGETS+=	error-check

.PHONY: real-test
real-test: ${_REAL_TEST_TARGETS}

.PHONY: test-message
test-message:
	@${PHASE_MSG} "Testing for ${PKGNAME}"

######################################################################
### test-check-interactive (PRIVATE)
######################################################################
### test-check-interactive checks whether we must do an interactive
### test or not.
###
test-check-interactive:
.if !empty(INTERACTIVE_STAGE:Mtest) && defined(BATCH)
	@${ERROR_MSG} "The test stage of this package requires user interaction"
	@${ERROR_MSG} "Please test manually with:"
	@${ERROR_MSG} "    \"cd ${.CURDIR} && ${MAKE} test\""
	@${TOUCH} ${_INTERACTIVE_COOKIE}
	@${FALSE}
.else
	@${DO_NADA}
.endif

######################################################################
### pre-test, do-test, post-test (PUBLIC, override)
######################################################################
### {pre,do,post}-test are the heart of the package-customizable
### test targets, and may be overridden within a package Makefile.
###
.PHONY: pre-test do-test post-test

.if !target(do-test)
.  if defined(TEST_TARGET) && !empty(TEST_TARGET)
do-test:
.    for _dir_ in ${TEST_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}			\
	cd ${WRKSRC} && cd ${_dir_} &&					\
	${TEST_MAKE_CMD} ${TEST_TARGET}
.    endfor
.  else
do-test:
	@${DO_NADA}
.  endif
.endif

.if !target(pre-test)
pre-test:
	@${DO_NADA}
.endif

.if !target(post-test)
post-test:
	@${DO_NADA}
.endif

######################################################################
### test-cookie (PRIVATE)
######################################################################
### test-cookie creates the "test" cookie file.
###
.PHONY: test-cookie
test-cookie:
	${_PKG_SILENT}${_PKG_DEBUG}${TEST} ! -f ${_COOKIE.test} || ${FALSE}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_COOKIE.test:H}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} ${PKGNAME} > ${_COOKIE.test}
