# $NetBSD: install.mk,v 1.32 2007/01/06 20:15:26 rillig Exp $
#
# This file provides the code for the "install" phase.
#
# Public targets:
#
# install:
#	Installs the package files into LOCALBASE.
#

# Interface for other infrastructure components:
#
# Hooks for use by the infrastructure:
#
# privileged-install-hook:
#	This hook is placed after the package has been installed,
#	before leaving the privileged mode.
#
# unprivileged-install-hook:
#	This hook is placed _before_ switching to privileged mode
#	in order to install the package.
#

######################################################################
### install (PUBLIC)
######################################################################
### install is a public target to install the package.  It will
### acquire elevated privileges just-in-time.
###
_INSTALL_TARGETS+=	check-vulnerable
_INSTALL_TARGETS+=	${_PKGSRC_BUILD_TARGETS}
_INSTALL_TARGETS+=	acquire-install-lock
_INSTALL_TARGETS+=	${_COOKIE.install}
_INSTALL_TARGETS+=	release-install-lock

.PHONY: install
.if !target(install)
.  if exists(${_COOKIE.install})
install:
	@${DO_NADA}
.  elif defined(_PKGSRC_BARRIER)
install: ${_INSTALL_TARGETS}
.  else
install: barrier
.  endif
.endif

.PHONY: acquire-install-lock release-install-lock
acquire-install-lock: acquire-lock
release-install-lock: release-lock

.if exists(${_COOKIE.install})
${_COOKIE.install}:
	@${DO_NADA}
.else
${_COOKIE.install}: real-install
.endif

######################################################################
### real-install (PRIVATE)
######################################################################
### real-install is a helper target onto which one can hook all of the
### targets that do the actual installing of the built objects.
###
_REAL_INSTALL_TARGETS+=	install-check-interactive
_REAL_INSTALL_TARGETS+=	install-check-version
_REAL_INSTALL_TARGETS+=	install-message
_REAL_INSTALL_TARGETS+=	install-vars
_REAL_INSTALL_TARGETS+=	unprivileged-install-hook
_REAL_INSTALL_TARGETS+=	install-all
_REAL_INSTALL_TARGETS+=	install-cookie

.PHONY: real-install
real-install: ${_REAL_INSTALL_TARGETS}

.PHONY: install-message
install-message:
	@${PHASE_MSG} "Installing for ${PKGNAME}"

######################################################################
### install-check-interactive (PRIVATE)
######################################################################
### install-check-interactive checks whether we must do an interactive
### install or not.
###
install-check-interactive:
.if !empty(INTERACTIVE_STAGE:Minstall) && defined(BATCH)
	@${ERROR_MSG} "The installation stage of this package requires user interaction"
	@${ERROR_MSG} "Please install manually with:"
	@${ERROR_MSG} "	\"cd ${.CURDIR} && ${MAKE} install\""
	@${TOUCH} ${_INTERACTIVE_COOKIE}
	@${FALSE}
.else
	@${DO_NADA}
.endif

.PHONY: unprivileged-install-hook
unprivileged-install-hook:
	@${DO_NADA}

######################################################################
### install-check-version (PRIVATE)
######################################################################
### install-check-version will verify that the built package located in
### ${WRKDIR} matches the version specified in the package Makefile.
### This is a check against stale work directories.
###
.PHONY: install-check-version
install-check-version: ${_COOKIE.extract}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	extractname=`${CAT} ${_COOKIE.extract}`;			\
	pkgname=${PKGNAME};						\
	case "$$extractname" in						\
	"")	${WARNING_MSG} "${WRKDIR} may contain an older version of ${PKGBASE}" ;; \
	"$$pkgname")	;;						\
	*)	${WARNING_MSG} "Package version $$extractname in ${WRKDIR}"; \
		${WARNING_MSG} "Current version $$pkgname in ${PKGPATH}"; \
		${WARNING_MSG} "Cleaning and rebuilding $$pkgname...";	\
		${RECURSIVE_MAKE} clean build ;;			\
	esac

######################################################################
### The targets below are run with elevated privileges.
######################################################################

.PHONY: acquire-install-localbase-lock release-install-localbase-lock
acquire-install-localbase-lock: acquire-localbase-lock
release-install-localbase-lock: release-localbase-lock

######################################################################
### install-all, su-install-all (PRIVATE)
######################################################################
### install-all is a helper target to run the install target of
### the built software, register the software installation, and run
### some sanity checks.
###
.if ${_USE_DESTDIR} != "user-destdir"
_INSTALL_ALL_TARGETS+=		acquire-install-localbase-lock
.endif
.if !defined(NO_PKG_REGISTER) && !defined(FORCE_PKG_REGISTER) && ${_USE_DESTDIR} == "no"
_INSTALL_ALL_TARGETS+=		install-check-conflicts
_INSTALL_ALL_TARGETS+=		install-check-installed
.endif
_INSTALL_ALL_TARGETS+=		install-check-umask
.if empty(CHECK_FILES:M[nN][oO]) && !empty(CHECK_FILES_SUPPORTED:M[Yy][Ee][Ss])
_INSTALL_ALL_TARGETS+=		check-files-pre
.endif
_INSTALL_ALL_TARGETS+=		install-makedirs
.if !empty(INSTALLATION_DIRS_FROM_PLIST:M[Yy][Ee][Ss])
_INSTALL_ALL_TARGETS+=		install-dirs-from-PLIST
.endif
.if ${_USE_DESTDIR} == "no"
_INSTALL_ALL_TARGETS+=		pre-install-script
.endif
_INSTALL_ALL_TARGETS+=		pre-install
_INSTALL_ALL_TARGETS+=		do-install
_INSTALL_ALL_TARGETS+=		post-install
_INSTALL_ALL_TARGETS+=		plist
_INSTALL_ALL_TARGETS+=		install-doc-handling
_INSTALL_ALL_TARGETS+=		install-script-data
.if empty(CHECK_FILES:M[nN][oO]) && !empty(CHECK_FILES_SUPPORTED:M[Yy][Ee][Ss])
_INSTALL_ALL_TARGETS+=		check-files-post
.endif
.if ${_USE_DESTDIR} == "no"
_INSTALL_ALL_TARGETS+=		post-install-script
.endif
.if !defined(NO_PKG_REGISTER) && ${_USE_DESTDIR} == "no"
_INSTALL_ALL_TARGETS+=		register-pkg
.endif
_INSTALL_ALL_TARGETS+=		privileged-install-hook
.if ${_USE_DESTDIR} != "user-destdir"
_INSTALL_ALL_TARGETS+=		release-install-localbase-lock
.endif
_INSTALL_ALL_TARGETS+=		error-check

.PHONY: install-all su-install-all
.  if !empty(_MAKE_INSTALL_AS_ROOT:M[Yy][Ee][Ss])
install-all: su-target
.  else
install-all: su-install-all
.  endif
su-install-all: ${_INSTALL_ALL_TARGETS}

######################################################################
### install-check-conflicts (PRIVATE, override)
######################################################################
### install-check-conflicts check for conflicts between the package and
### any installed packages.  This should be overridden per package
### system flavor.
###
.PHONY: install-check-conflicts
.if !target(install-check-conflicts)
install-check-conflicts:
	@${DO_NADA}
.endif

######################################################################
### install-check-installed (PRIVATE, override)
######################################################################
### install-check-installed checks if the package (perhaps an older
### version) is already installed on the system.  This should be
### overridden per package system flavor.
###
.PHONY: install-check-installed
.if !target(install-check-installed)
install-check-installed:
	@${DO_NADA}
.endif

######################################################################
### install-check-umask (PRIVATE)
######################################################################
### install-check-umask tests whether the umask is properly set and
### emits a non-fatal warning otherwise.
###
.PHONY: install-check-umask
install-check-umask:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	umask=`${SH} -c umask`;						\
	if ${TEST} "$$umask" -ne ${DEF_UMASK}; then			\
		${WARNING_MSG} "Your umask is \`\`$$umask''.";	\
		${WARNING_MSG} "If this is not desired, set it to an appropriate value (${DEF_UMASK}) and install"; \
		${WARNING_MSG} "this package again by \`\`${MAKE} deinstall reinstall''."; \
        fi

######################################################################
### install-makedirs (PRIVATE)
######################################################################
### install-makedirs is a target to create directories expected to
### exist prior to installation.  If a package sets INSTALLATION_DIRS,
### then it's known to pre-create all of the directories that it needs
### at install-time, so we don't need mtree to do it for us.
###
MTREE_FILE?=	${PKGSRCDIR}/mk/platform/${OPSYS}.pkg.dist
MTREE_ARGS?=	-U -f ${MTREE_FILE} -d -e -p

.PHONY: install-makedirs
install-makedirs:
	${_PKG_SILENT}${_PKG_DEBUG}${INSTALL_DATA_DIR} ${DESTDIR}${PREFIX}
.if !defined(NO_MTREE)
	${_PKG_SILENT}${_PKG_DEBUG}${TEST} ! -f ${MTREE_FILE} ||	\
		${MTREE} ${MTREE_ARGS} ${DESTDIR}${PREFIX}/
.endif
.if defined(INSTALLATION_DIRS) && !empty(INSTALLATION_DIRS)
	@${STEP_MSG} "Creating installation directories"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for dir in ${INSTALLATION_DIRS}; do				\
		case "$$dir" in						\
		${PREFIX}/*)						\
			dir=`${ECHO} $$dir | ${SED} "s|^${PREFIX}/||"` ;; \
		/*)	continue ;;					\
		esac;							\
		if [ -f "${PREFIX}/$$dir" ]; then			\
			${ERROR_MSG} "[install.mk] $$dir should be a directory, but is a file."; \
			exit 1;						\
		fi;							\
		case "$$dir" in						\
		*bin|*bin/*|*libexec|*libexec/*)			\
			${INSTALL_PROGRAM_DIR} ${DESTDIR}${PREFIX}/$$dir ;;	\
		${PKGMANDIR}/*)						\
			${INSTALL_MAN_DIR} ${DESTDIR}${PREFIX}/$$dir ;;		\
		*)							\
			${INSTALL_DATA_DIR} ${DESTDIR}${PREFIX}/$$dir ;;	\
		esac;							\
	done
.endif	# INSTALLATION_DIRS

# Creates the directories for all files that are mentioned in the static
# PLIST files of the package, to make the declaration of
# INSTALLATION_DIRS redundant in some cases.
#
# To enable this, the variable INSTALLATION_DIRS_FROM_PLIST must be set
# to "yes".
#
.PHONY: install-dirs-from-PLIST
install-dirs-from-PLIST:
	@${STEP_MSG} "Creating installation directories from PLIST files"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${CAT} ${PLIST_SRC} | sed -n -e 's,\\,\\\\,' -e 's,^man,${PKGMANDIR},' -e 's,^\([^$$@]*\)/[^/]*$$,\1,p' \
	| while read dir; do						\
		if [ -f "${DESTDIR}/${PREFIX}/$$dir" ]; then		\
			${ERROR_MSG} "[install.mk] $$dir should be a directory, but is a file."; \
			exit 1;						\
		fi;							\
		case "$$dir" in						\
		*bin|*bin/*|*libexec|*libexec/*)			\
			${INSTALL_PROGRAM_DIR} "${DESTDIR}${PREFIX}/$$dir";; \
		${PKGMANDIR}/*)						\
			${INSTALL_MAN_DIR} "${DESTDIR}${PREFIX}/$$dir";; \
		*)							\
			${INSTALL_DATA_DIR} "${DESTDIR}${PREFIX}/$$dir";; \
		esac;							\
	done

######################################################################
### pre-install, do-install, post-install (PUBLIC, override)
######################################################################
### {pre,do,post}-install are the heart of the package-customizable
### install targets, and may be overridden within a package Makefile.
###
.PHONY: pre-install do-install post-install

INSTALL_DIRS?=		${BUILD_DIRS}
INSTALL_MAKE_FLAGS?=	# none
INSTALL_TARGET?=	install ${USE_IMAKE:D${NO_INSTALL_MANPAGES:D:Uinstall.man}}
.if ${_USE_DESTDIR} != "no"
INSTALL_ENV+=		DESTDIR=${DESTDIR:Q}
INSTALL_MAKE_FLAGS+=	DESTDIR=${DESTDIR:Q}
.endif

.if !target(do-install)
do-install:
.  for _dir_ in ${INSTALL_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}			\
	cd ${WRKSRC} && cd ${_dir_} &&					\
	${SETENV} ${INSTALL_ENV} ${MAKE_ENV} 				\
		${MAKE_PROGRAM} ${MAKE_FLAGS} ${INSTALL_MAKE_FLAGS}	\
			-f ${MAKE_FILE} ${INSTALL_TARGET}
.  endfor
.endif

.if !target(pre-install)
pre-install:
	@${DO_NADA}
.endif
.if !target(post-install)
post-install:
	@${DO_NADA}
.endif

######################################################################
### install-doc-handling (PRIVATE)
######################################################################
### install-doc-handling does automatic document (de)compression based
### on the contents of the PLIST.
###
_PLIST_REGEXP.info=	\
	^([^\/]*\/)*${PKGINFODIR}/[^/]*(\.info)?(-[0-9]+)?(\.gz)?$$
_PLIST_REGEXP.man=	\
	^([^/]*/)+(man[1-9ln]/[^/]*\.[1-9ln]|cat[1-9ln]/[^/]*\.[0-9])(\.gz)?$$

_DOC_COMPRESS=								\
	${SETENV} PATH=${PATH:Q}					\
		MANZ=${_MANZ}						\
		PKG_VERBOSE=${PKG_VERBOSE}				\
		TEST=${TOOLS_TEST:Q}					\
	${SH} ${PKGSRCDIR}/mk/plist/doc-compress ${DESTDIR}${PREFIX}

.PHONY: install-doc-handling
install-doc-handling: plist
	@${STEP_MSG} "Automatic manual page handling"
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${PLIST} | ${GREP} -v "^@" |	\
	${EGREP} ${_PLIST_REGEXP.man:Q} | ${_DOC_COMPRESS}

######################################################################
### register-pkg (PRIVATE, override)
######################################################################
### register-pkg registers the package as being installed on the system.
###
.PHONY: register-pkg
.if !target(register-pkg)
register-pkg:
	@${DO_NADA}
.endif

privileged-install-hook: .PHONY
	@${DO_NADA}

######################################################################
### install-clean (PRIVATE)
######################################################################
### install-clean removes the state files for the "install" and
### later phases so that the "install" target may be re-invoked.
###
install-clean: package-clean check-clean
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PLIST} ${_COOKIE.install}

######################################################################
### bootstrap-register (PUBLIC)
######################################################################
### bootstrap-register registers "bootstrap" packages that are installed
### by the pkgsrc/bootstrap/bootstrap script.
###
bootstrap-register: register-pkg clean
	@${DO_NADA}
