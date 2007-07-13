# $NetBSD: package.mk,v 1.7 2007/07/13 14:42:53 joerg Exp $

PKG_SUFX?=		.tgz
PKGFILE?=		${PKGREPOSITORY}/${PKGNAME}${PKG_SUFX}
PKGREPOSITORY?=		${PACKAGES}/${PKGREPOSITORYSUBDIR}
PKGREPOSITORYSUBDIR?=	All

######################################################################
### package-check-installed (PRIVATE, pkgsrc/mk/package/package.mk)
######################################################################
### package-check-installed verifies that the package is installed on
### the system.
###
.PHONY: package-check-installed
package-check-installed:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${PKG_INFO} -qe ${PKGNAME};					\
	if ${TEST} $$? -ne 0; then					\
		${ERROR_MSG} "${PKGNAME} is not installed.";		\
		exit 1;							\
	fi

######################################################################
### package-create (PRIVATE, pkgsrc/mk/package/package.mk)
######################################################################
### package-create creates the binary package.
###
.PHONY: package-create
package-create: package-remove ${PKGFILE} package-links

_PKG_ARGS_PACKAGE+=	${_PKG_CREATE_ARGS}
.if ${_USE_DESTDIR} == "no"
_PKG_ARGS_PACKAGE+=	-p ${PREFIX}
.else
_PKG_ARGS_PACKAGE+=	-I ${PREFIX} -p ${DESTDIR}${PREFIX}
.endif
_PKG_ARGS_PACKAGE+=	-L ${DESTDIR}${PREFIX}			# @src ...
.if ${PKG_INSTALLATION_TYPE} == "pkgviews"
_PKG_ARGS_PACKAGE+=	-E
.endif

${PKGFILE}: ${_CONTENTS_TARGETS}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG} set -e;				\
	${PKG_CREATE} ${_PKG_ARGS_PACKAGE} ${.TARGET} || {		\
		exitcode=$$?;						\
		${ERROR_MSG} "${PKG_CREATE:T} failed ($$exitcode)";	\
		${RM} -f ${.TARGET};					\
		exit 1;							\
	}

######################################################################
### package-remove (PRIVATE)
######################################################################
### package-remove removes the binary package from the package
### repository.
###
.PHONY: package-remove
package-remove:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PKGFILE}

######################################################################
### package-links (PRIVATE)
######################################################################
### package-links creates symlinks to the binary package from the
### non-primary categories to which the package belongs.
###
package-links: delete-package-links
.for _dir_ in ${CATEGORIES:S/^/${PACKAGES}\//}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_dir_:Q}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} ! -d ${_dir_:Q}; then				\
		${ERROR_MSG} "Can't create directory "${_dir_:Q}".";	\
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${_dir_:Q}/${PKGFILE:T}
	${_PKG_SILENT}${_PKG_DEBUG}${LN} -s ../${PKGREPOSITORYSUBDIR}/${PKGFILE:T} ${_dir_:Q}
.endfor

######################################################################
### delete-package-links (PRIVATE)
######################################################################
### delete-package-links removes the symlinks to the binary package from
### the non-primary categories to which the package belongs.
###
delete-package-links:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${FIND} ${PACKAGES} -type l -name ${PKGFILE:T} -print |		\
	${XARGS} ${RM} -f

######################################################################
### tarup (PUBLIC)
######################################################################
### tarup is a public target to generate a binary package from an
### installed package instance.
###
_PKG_TARUP_CMD= ${LOCALBASE}/bin/pkg_tarup

.PHONY: tarup
tarup: package-remove tarup-pkg package-links

######################################################################
### tarup-pkg (PRIVATE)
######################################################################
### tarup-pkg creates a binary package from an installed package instance
### using "pkg_tarup".
###
tarup-pkg:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} -x ${_PKG_TARUP_CMD} || exit 1;				\
	${SETENV} PKG_DBDIR=${_PKG_DBDIR} PKG_SUFX=${PKG_SUFX}		\
		PKGREPOSITORY=${PKGREPOSITORY}				\
		${_PKG_TARUP_CMD} ${PKGNAME}

######################################################################
### package-install (PUBLIC)
######################################################################
### When DESTDIR support is active, package-install uses package to
### create a binary package and installs it.
### Otherwise it is identical to calling package.
###

.PHONY: package-install real-package-install su-real-package-install
.if defined(_PKGSRC_BARRIER)
package-install: package real-package-install
.else
package-install: barrier
.endif

.if ${_USE_DESTDIR} != "no"
real-package-install: su-target
.else
real-package-install:
	@${DO_NADA}
.endif

su-real-package-install:
	@${PHASE_MSG} "Install binary package of "${PKGNAME:Q}
	${PKG_ADD} ${PKGFILE}
