# $NetBSD: sunpro.mk,v 1.21 2004/08/27 06:29:09 jlam Exp $

.if !defined(COMPILER_SUNPRO_MK)
COMPILER_SUNPRO_MK=	defined

.include "../../mk/bsd.prefs.mk"

SUNWSPROBASE?=	/opt/SUNWspro

# LANGUAGES.<compiler> is the list of supported languages by the compiler.
# _LANGUAGES.<compiler> is ${LANGUAGES.<compiler>} restricted to the ones
# requested by the package in USE_LANGUAGES.
#
LANGUAGES.sunpro=	c c++
_LANGUAGES.sunpro=	# empty
.for _lang_ in ${USE_LANGUAGES}
_LANGUAGES.sunpro+=	${LANGUAGES.sunpro:M${_lang_}}
.endfor

_SUNPRO_DIR=	${WRKDIR}/.sunpro
_SUNPRO_LINKS=	# empty
.if exists(${SUNWSPROBASE}/bin/cc)
_SUNPRO_CC=	${_SUNPRO_DIR}/bin/cc
_SUNPRO_LINKS+=	_SUNPRO_CC
PKG_CC=		${_SUNPRO_CC}
CC=		${PKG_CC:T}
.endif
.if exists(${SUNWSPROBASE}/bin/CC)
_SUNPRO_CXX=	${_SUNPRO_DIR}/bin/CC
_SUNPRO_LINKS+=	_SUNPRO_CXX
PKG_CXX=	${_SUNPRO_CXX}
CXX=		${PKG_CXX:T}
.endif

# SunPro passes rpath directives to the linker using "-R".
_LINKER_RPATH_FLAG=	-R

# SunPro passes rpath directives to the linker using "-R".
_COMPILER_RPATH_FLAG=	-R

.if exists(${SUNWSPROBASE}/bin/cc)
CC_VERSION_STRING!=	${SUNWSPROBASE}/bin/cc -V 2>&1 || ${TRUE}
CC_VERSION!=		${SUNWSPROBASE}/bin/cc -V 2>&1 | ${GREP} '^cc'
.else
CC_VERSION_STRING?=	${CC_VERSION}
CC_VERSION?=		cc: Sun C
.endif

# Prepend the path to the compiler to the PATH.
.if !empty(_LANGUAGES.sunpro)
PREPEND_PATH+=	${_SUNPRO_DIR}/bin
.endif

# Create compiler driver scripts in ${WRKDIR}.
.for _target_ in ${_SUNPRO_LINKS}
.  if !target(${${_target_}})
override-tools: ${${_target_}}        
${${_target_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${ECHO} '#!${TOOLS_SHELL}';					\
	 ${ECHO} 'exec ${SUNWSPROBASE}/bin/${${_target_}:T} "$$@"';	\
	) > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.  endif
.endfor

.endif	# COMPILER_SUNPRO_MK
