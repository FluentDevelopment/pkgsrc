# $NetBSD: ccache.mk,v 1.14 2004/02/12 08:54:48 jlam Exp $

.if !defined(COMPILER_CCACHE_MK)
COMPILER_CCACHE_MK=	one

.  if !empty(PKGPATH:Mdevel/ccache)
IGNORE_CCACHE=	yes
MAKEFLAGS+=	IGNORE_CCACHE=yes
.  endif

.  if defined(IGNORE_CCACHE)
_USE_CCACHE=	NO
.  endif

# LANGUAGES.<compiler> is the list of supported languages by the compiler.
# _LANGUAGES.<compiler> is ${LANGUAGES.<compiler>} restricted to the ones
# requested by the package in USE_LANGUAGES.
# 
LANGUAGES.ccache=	c c++
_LANGUAGES.ccache=	# empty
.  for _lang_ in ${USE_LANGUAGES}
_LANGUAGES.ccache+=	${LANGUAGES.ccache:M${_lang_}}
.  endfor
.  if empty(_LANGUAGES.ccache)
_USE_CCACHE=	NO
.  endif

.  if !defined(_USE_CCACHE)
_USE_CCACHE=	YES
.  endif

.  if !empty(_USE_CCACHE:M[yY][eE][sS])
EVAL_PREFIX+=		_CCACHEBASE=ccache
_CCACHEBASE_DEFAULT=	${LOCALBASE}
_CCACHEBASE?=		${LOCALBASE}

.    if exists(${_CCACHEBASE}/bin/ccache)
_CCACHE_DIR=	${WRKDIR}/.ccache
_CCACHE_LINKS=	# empty
.      if !empty(_LANGUAGES.ccache:Mc)
_CCACHE_CC:=	${_CCACHE_DIR}/bin/${PKG_CC:T}
_CCACHE_LINKS+=	_CCACHE_CC
PKG_CC:=	${_CCACHE_CC}
CC=		${PKG_CC:T}
.      endif
.      if !empty(_LANGUAGES.ccache:Mc++)
_CCACHE_CXX:=	${_CCACHE_DIR}/bin/${PKG_CXX:T}
_CCACHE_LINKS+=	_CCACHE_CXX
PKG_CXX:=	${_CCACHE_CXX}
CXX=		${PKG_CXX:T}
.      endif
.    endif
.  endif
.endif	# COMPILER_CCACHE_MK

# The following section is included only if we're not being included by
# bsd.prefs.mk.
#
.if empty(BSD_PREFS_MK)
.  if empty(COMPILER_CCACHE_MK:Mtwo)
COMPILER_CCACHE_MK+=	two

# Prepend the path the to the compiler to the PATH
.    if !empty(_USE_CCACHE:M[yY][eE][sS])
.      if !empty(_LANGUAGES.ccache)
.        if empty(PREPEND_PATH:M${_CCACHE_DIR}/bin)
PREPEND_PATH+=	${_CCACHE_DIR}/bin
PATH:=		${_CCACHE_DIR}/bin:${PATH}
.        endif
.      endif

# Add the dependency on ccache.
BUILD_DEPENDS+=	ccache-[0-9]*:../../devel/ccache

# Override the compiler-specific hash with the version string for the
# compiler.
#
CONFIGURE_ENV+=	CCACHE_HASHCC=${CC_VERSION_STRING:Q}
MAKE_ENV+=	CCACHE_HASHCC=${CC_VERSION_STRING:Q}

# Create symlinks for the compiler into ${WRKDIR}.
.      if exists(${_CCACHEBASE}/bin/ccache)
.        for _target_ in ${_CCACHE_LINKS}
.          if !target(${${_target_}})
override-tools: ${${_target_}}
${${_target_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${LN} -fs ${_CCACHEBASE}/bin/ccache ${.TARGET}
.          endif
.        endfor
.      endif
.    endif
.  endif # COMPILER_CCACHE_MK
.endif	 # BSD_PREFS_MK
