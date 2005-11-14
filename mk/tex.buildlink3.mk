# $NetBSD: tex.buildlink3.mk,v 1.4 2005/11/14 02:38:37 minskim Exp $
#
# A Makefile fragment for tex and latex packages
#
# 	* Determine the version of teTeX to be used.
#     Modify TEX_DEFAULT to change the default version (default to teTeX2)
#
#	* tex files are installed...
#	  	teTeX[1-2]
#	  		-> ${PREFIX}/share/texmf
#		  teTeX3
#	  		->${PREFIX}/share/texmf-local
#   The variables PKG_TEXMFPREFIX and PKG_LOCALTEXMFPREFIX defines the main
#   texmf tree, where teTeX should install his own texmf tree, and the local
#   texmf tree, which is the place where other packages should install their
#   latex files, like additional styles.
#   NOTE: before all latex related packages are converted to use these
#   variables, we will keep
#   PKG_TEXMFPREFIX=PKG_LOCALTEXMFPREFIX=${PREFIX}/share/texmf
#
#	* Assume each package supports teTeX{2,3} by default.
#	  To change the supported latex versions, define TEX_ACCEPTED
#	  explicitly before including mk/latex.buildlink3.mk.  Note that the order is
#	  important.
#
# * Optionally set TEX_DEPMETHOD to "build" to only add a build-time
#   dependency on Latex. That may be useful for creating documentation
#
# Variables for users:
#
# TEX_DEFAULT
#   Description:
#     The user's favorite latex implementation
#   Possible values:
#     teTeX1, teTeX2, teTeX3
#   Default value:
#     teTeX2
#
# Variables tex packages can provide:
#
# TEX_DEPMETHOD
#  Description:
#    Set latex as DEPENDS or BUILD_DEPENDS
#  Possible values:
#    run, build
#  Default value:
#    run
#
# TEX_ACCEPTED
#  Description:
#    Versions the package accepts (supports).
#  Possible values:
#    teTeX1, teTeX2, teTeX3
#  Default value:
#    teTeX2, teTeX3
#
# Variables provided for tex packages:
#
# PKG_TEXMFPREFIX
#   Description:
#     Path to the directory the standard tex files can be found
#   Possible values:
# 	  ${PREFIX}/share/texmf
# 	  ${PREFIX}/share/texmf-dist
#
# PKG_LOCALTEXMFPREFIX
#   Description:
#     Path to the directory the tex for extentions should be installed into
#   Possible values:
#   	${PREFIX}/share/texmf
#     ${PREFIX}/share/texmf-local
#
# TEX_TYPE
#   Description:
#     The type of the used latex package
#   Possible values:
#     teTeX1, teTeX2, teTeX3

.if !defined(TEX_BUILDLINK3_MK)
TEX_BUILDLINK3_MK=	# defined

.include "../../mk/bsd.prefs.mk"

TEX_DEFAULT?=		teTeX2
TEX_DEPMETHOD?= run

# Assume only teTeX {2-3} are supported by default.
TEX_ACCEPTED?=	teTeX2 teTeX3

# set up variables for buildlink or depends
#
BUILDLINK_DEPENDS.teTeX1=	teTeX-bin-1.[0-9]*
BUILDLINK_PKGSRCDIR.teTeX1=	../../print/teTeX1-bin
BUILDLINK_DEPENDS.teTeX2=	teTeX-bin-2.[0-9]*
BUILDLINK_PKGSRCDIR.teTeX2=	../../print/teTeX-bin
BUILDLINK_DEPENDS.teTeX3=	teTeX-bin-3.[0-9]*
BUILDLINK_PKGSRCDIR.teTeX3=	../../print/teTeX3-bin

# Determine the Latex version to be used.
#
.if !defined(_TEX_TYPE)
_TEX_TYPE=	${TEX_DEFAULT}
.endif

.if !empty(TEX_ACCEPTED:M${_TEX_TYPE})
TEX_TYPE=	${_TEX_TYPE}
.else
TEX_TYPE=	none
.endif

# Set version specifics.
#
.if ${TEX_TYPE} == "teTeX3"
_TEX_DEPENDENCY=	${BUILDLINK_DEPENDS.teTeX3}
_TEX_PKGSRCDIR=	${BUILDLINK_PKGSRCDIR.teTeX3}
#PKG_TEXMFPREFIX=	${PREFIX}/share/texmf-dist
PKG_TEXMFPREFIX=	${PREFIX}/share/texmf
#PKG_LOCALTEXMFPREFIX=	${PREFIX}/share/texmf-local
PKG_LOCALTEXMFPREFIX=	${PREFIX}/share/texmf
.elif ${TEX_TYPE} == "teTeX2"
_TEX_DEPENDENCY=	${BUILDLINK_DEPENDS.teTeX2}
_TEX_PKGSRCDIR=	${BUILDLINK_PKGSRCDIR.teTeX2}
PKG_TEXMFPREFIX=	${PREFIX}/share/texmf
PKG_LOCALTEXMFPREFIX=	${PREFIX}/share/texmf
.elif ${TEX_TYPE} == "teTeX1"
_TEX_DEPENDENCY=	${BUILDLINK_DEPENDS.teTeX1}
_TEX_PKGSRCDIR=	${BUILDLINK_PKGSRCDIR.teTeX1}
PKG_TEXMFPREFIX=	${PREFIX}/share/texmf
PKG_LOCALTEXMFPREFIX=	${PREFIX}/share/texmf
.endif

PLIST_SUBST+=	TEX_TYPE=${TEX_TYPE}
PLIST_SUBST+=	PKG_TEXMFPREFIX=${PKG_TEXMFPREFIX:C|^${PREFIX}/||}
PLIST_SUBST+=	PKG_LOCALTEXMFPREFIX=${PKG_LOCALTEXMFPREFIX:C|^${PREFIX}/||}

PRINT_PLIST_AWK+=	/^@dirrm ${PKG_LOCALTEXMFPREFIX:S|${PREFIX}/||:S|/|\\/|g}(\/bibtex(\/bib|\/bst)?|\/tex(\/latex)?)?$$/ \
			{ next; }
PRINT_PLIST_AWK+=	/^(@dirrm )?${PKG_LOCALTEXMFPREFIX:S|${PREFIX}/||:S|/|\\/|g}/ \
			{ gsub(/${PKG_LOCALTEXMFPREFIX:S|${PREFIX}/||:S|/|\\/|g}/, "$${PKG_LOCALTEXMFPREFIX}"); \
			print; next; }

.endif	# TEX_BUILDLINK3_MK

.if ${TEX_TYPE} == "none"
PKG_FAIL_REASON=	\
	"${_TEX_TYPE} is not an acceptable latex version for ${PKGNAME}."
.else
.if (${TEX_DEPMETHOD} == "build")
BUILD_DEPENDS+=	${_TEX_DEPENDENCY}:${_TEX_PKGSRCDIR}
.else
TEX_DEPMETHOD:= run
.  include "${_TEX_PKGSRCDIR}/buildlink3.mk"
.endif
.endif
