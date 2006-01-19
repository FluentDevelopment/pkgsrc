# $NetBSD: bsd.utils.mk,v 1.5 2006/01/19 00:40:00 jlam Exp $
#
# This Makefile fragment is included by bsd.pkg.mk and defines utility
# and otherwise miscellaneous variables and targets.
#

# DEPENDS_TYPE is used by the "show-depends-pkgpaths" target and specifies
# which class of dependencies to output.  The special value "all" means
# to output every dependency.
#
DEPENDS_TYPE?=  all
.if !empty(DEPENDS_TYPE:Mbuild) || !empty(DEPENDS_TYPE:Mall)
_ALL_DEPENDS_PKGSRCDIRS+=	${BUILD_DEPENDS:C/^[^:]*://}
.endif
.if !empty(DEPENDS_TYPE:Minstall) || !empty(DEPENDS_TYPE:Mpackage) || \
    !empty(DEPENDS_TYPE:Mall)
_ALL_DEPENDS_PKGSRCDIRS+=	${DEPENDS:C/^[^:]*://}
.endif

# _PKG_PATHS_CMD canonicalizes package paths so that they're relative to
# ${PKGSRCDIR} and also verifies that they exist within pkgsrc.
#
_PKG_PATHS_CMD=								\
	${SETENV} ECHO=${TOOLS_ECHO:Q} PKGSRCDIR=${PKGSRCDIR:Q}		\
		PWD_CMD=${TOOLS_PWD_CMD:Q} TEST=${TOOLS_TEST:Q}		\
	${SH} ${.CURDIR}/../../mk/scripts/pkg_path

.PHONY: show-depends-dirs show-depends-pkgpaths
show-depends-dirs show-depends-pkgpaths:
	@${_PKG_PATHS_CMD} ${_ALL_DEPENDS_PKGSRCDIRS:O:u}

# _DEPENDS_WALK_CMD holds the command (sans arguments) to walk the
# dependency graph for a package.
#
_DEPENDS_WALK_MAKEFLAGS?=	${MAKEFLAGS}
_DEPENDS_WALK_CMD=							\
	${SETENV} ECHO=${TOOLS_ECHO:Q} MAKE=${MAKE:Q}			\
		MAKEFLAGS=${_DEPENDS_WALK_MAKEFLAGS:Q}			\
		PKGSRCDIR=${PKGSRCDIR:Q} TEST=${TOOLS_TEST:Q}		\
	${AWK} -f ${.CURDIR}/../../mk/scripts/depends-depth-first.awk --

# show-all-depends-dirs prints a list of every dependency, implied and
# direct", of the current package, and includes the current package.
#
.PHONY: show-all-depends-dirs
show-all-depends-dirs:
	@${_DEPENDS_WALK_CMD} -r ${PKGPATH}

# show-all-depends-dirs-excl prints a list of every dependency, implied and
# direct", of the current package.
#
.PHONY: show-all-depends-dirs-excl
show-all-depends-dirs-excl:
	@${_DEPENDS_WALK_CMD} ${PKGPATH}
