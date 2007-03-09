# $NetBSD: install.mk,v 1.9 2007/03/09 00:39:55 rillig Exp $
#
# _flavor-check-conflicts:
#	Checks for conflicts between the package and installed packages.
#
#	XXX: Needs WRKDIR.
#
# _flavor-check-installed:
#	Checks if the package (or an older version of it) is already
#	installed on the system.
#
#	XXX: Needs WRKDIR.
#
# _flavor-register:
#	Populates the package database with the appropriate entries to
#	register the package as being installed on the system.
#

_flavor-check-conflicts: .PHONY error-check
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR}/.CONFLICTS
.for _conflict_ in ${CONFLICTS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${_PKG_BEST_EXISTS} ${_conflict_:Q} || ${TRUE}`";	\
	case "$$found" in						\
	"")	;;							\
	*)	${ECHO} "$$found" >> ${WRKDIR}/.CONFLICTS ;;		\
	esac
.endfor
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} -f ${WRKDIR}/.CONFLICTS || exit 0;			\
	exec 1>${ERROR_DIR}/${.TARGET};					\
	${ECHO} "${PKGNAME} conflicts with installed package(s):";	\
	${CAT} ${WRKDIR}/.CONFLICTS | ${SED} -e "s|^|    |";		\
	${ECHO} "They install the same files into the same place.";	\
	${ECHO} "Please remove conflicts first with pkg_delete(1).";	\
	${RM} -f ${WRKDIR}/.CONFLICTS

_flavor-check-installed: .PHONY error-check
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${_PKG_BEST_EXISTS} ${PKGWILDCARD:Q} || ${TRUE}`";	\
	${TEST} -n "$$found" || exit 0;					\
	exec 1>${ERROR_DIR}/${.TARGET};					\
	${ECHO} "$$found is already installed - perhaps an older version?"; \
	${ECHO} "If so, you may use either of:";			\
	${ECHO} "    - \"pkg_delete $$found\" and \"${MAKE} reinstall\""; \
	${ECHO} "      to upgrade properly";				\
	${ECHO} "    - \"${MAKE} update\" to rebuild the package and all"; \
	${ECHO} "      of its dependencies";				\
	${ECHO} "    - \"${MAKE} replace\" to replace only the package without"; \
	${ECHO} "      re-linking dependencies, risking various problems."

_REGISTER_DEPENDENCIES=							\
	${SETENV} PKG_DBDIR=${_PKG_DBDIR:Q}				\
		AWK=${TOOLS_AWK:Q}					\
		PKG_ADMIN=${PKG_ADMIN_CMD:Q}				\
	${SH} ${PKGSRCDIR}/mk/flavor/pkg/register-dependencies

_flavor-register: .PHONY generate-metadata ${_COOKIE.depends}
	@${STEP_MSG} "Registering installation for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -fr ${_PKG_DBDIR}/${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_PKG_DBDIR}/${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}${CP} ${PKG_DB_TMPDIR}/* ${_PKG_DBDIR}/${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_ADMIN} add ${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	case ${_AUTOMATIC:Q}"" in					\
	[yY][eE][sS])	${PKG_ADMIN} set automatic=yes ${PKGNAME} ;;	\
	esac
	${_PKG_SILENT}${_PKG_DEBUG}${_DEPENDS_PATTERNS_CMD} |		\
		${SORT} -u | ${_REGISTER_DEPENDENCIES} ${PKGNAME}
