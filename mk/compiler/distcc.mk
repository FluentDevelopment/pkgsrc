# $NetBSD: distcc.mk,v 1.6 2004/02/02 11:03:08 jlam Exp $

.if !defined(COMPILER_DISTCC_MK)
COMPILER_DISTCC_MK=	defined

.if !empty(PKGPATH:Mdevel/distcc)
IGNORE_DISTCC=	yes
MAKEFLAGS+=	IGNORE_DISTCC=yes
.endif

.if defined(IGNORE_DISTCC)
_USE_DISTCC=	NO
.endif

# LANGUAGES.<compiler> is the list of supported languages by the compiler.
# _LANGUAGES.<compiler> is ${LANGUAGES.<compiler>} restricted to the ones
# requested by the package in USE_LANGUAGES.
# 
LANGUAGES.distcc=	c c++
_LANGUAGES.distcc=	# empty
.for _lang_ in ${USE_LANGUAGES}
_LANGUAGES.distcc=	${LANGUAGES.distcc:M${_lang_}}
.endfor
.if empty(_LANGUAGES.distcc)
_USE_CCACHE=	NO
.endif

.if !defined(_USE_DISTCC)
_USE_DISTCC=	YES
.endif

.if !empty(_USE_DISTCC:M[yY][eE][sS])
#
# Add the dependency on distcc.
BUILD_DEPENDS+=	distcc-[0-9]*:../../devel/distcc
.endif

EVAL_PREFIX+=	_DISTCCBASE=distcc
_DISTCCBASE_DEFAULT=	${LOCALBASE}
_DISTCCBASE?=		${LOCALBASE}

.if exists(${_DISTCCBASE}/bin/distcc)
_DISTCC_DIR=	${WRKDIR}/.distcc
PATH:=		${_DISTCC_DIR}/bin:${PATH}

_DISTCC_LINKS=	# empty
.  if !empty(_LANGUAGES.distcc:Mc)
CC:=	${_DISTCC_DIR}/bin/${CC:T}
_DISTCC_LINKS+=	CC
.  endif
.  if !empty(_LANGUAGES.distcc:Mc++)
CXX:=	${_DISTCC_DIR}/bin/${CXX:T}
_DISTCC_LINKS+=	CXX
.  endif

.  for _target_ in ${_DISTCC_LINKS}
override-tools: ${${_target_}}
${${_target_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${LN} -fs ${_DISTCCBASE}/bin/distcc ${.TARGET}
.  endfor
.endif

.endif	# COMPILER_DISTCC_MK
