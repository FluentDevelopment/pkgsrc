# $NetBSD: builtin.mk,v 1.2 2004/03/15 16:48:18 jlam Exp $

_GL_GLX_H=	${X11BASE}/include/GL/glx.h
_X11_TMPL=	${X11BASE}/lib/X11/config/X11.tmpl

# Distill the MESA_REQD list into a single _MESA_REQD value that is the
# highest version of MESA required.
#
_MESA_STRICTEST_REQD?=	none
.  for _version_ in ${MESA_REQD}
.    for _pkg_ in MesaLib-${_version_}
.      if ${_MESA_STRICTEST_REQD} == "none"
_MESA_PKG_SATISFIES_DEP=	yes
.        for _vers_ in ${MESA_REQD}
.          if !empty(_MESA_PKG_SATISFIES_DEP:M[yY][eE][sS])
_MESA_PKG_SATISFIES_DEP!=	\
	if ${PKG_ADMIN} pmatch 'MesaLib>=${_vers_}' ${_pkg_}; then	\
		${ECHO} "yes";						\
	else								\
		${ECHO} "no";						\
	fi
.          endif
.        endfor
.        if !empty(_MESA_PKG_SATISFIES_DEP:M[yY][eE][sS])
_MESA_STRICTEST_REQD=	${_version_}
.        endif
.      endif
.    endfor
.  endfor
_MESA_REQD=	${_MESA_STRICTEST_REQD}

.if !defined(IS_BUILTIN.MesaLib)
IS_BUILTIN.MesaLib=	no
.  if exists(${_GL_GLX_H}) && exists(${_X11_TMPL})
IS_BUILTIN.MesaLib!=							\
	if ${GREP} -q BuildGLXLibrary ${_X11_TMPL}; then		\
		${ECHO} "yes";						\
	else								\
		${ECHO} "no";						\
	fi
.    if !empty(IS_BUILTIN.MesaLib:M[yY][eE][sS])
#
# Create an appropriate package name for the built-in Mesa/GLX distributed
# with the system.  This package name can be used to check against
# BUILDLINK_DEPENDS.<pkg> to see if we need to install the pkgsrc version
# or if the built-in one is sufficient.
#
.      include "../../graphics/Mesa/version.mk"
BUILTIN_PKG.MesaLib=	MesaLib-${_MESA_VERSION}
MAKEFLAGS+=		BUILTIN_PKG.MesaLib=${BUILTIN_PKG.MesaLib}
.    endif
.  endif
MAKEFLAGS+=	IS_BUILTIN.MesaLib=${IS_BUILTIN.MesaLib}
.endif

CHECK_BUILTIN.MesaLib?=	no
.if !empty(CHECK_BUILTIN.MesaLib:M[yY][eE][sS])
USE_BUILTIN.MesaLib=	yes
.endif

.if !defined(USE_BUILTIN.MesaLib)
USE_BUILTIN.MesaLib?=	${IS_BUILTIN.MesaLib}

.  if defined(BUILTIN_PKG.MesaLib)
USE_BUILTIN.MesaLib=	yes
.    for _depend_ in ${BUILDLINK_DEPENDS.MesaLib}
.      if !empty(USE_BUILTIN.MesaLib:M[yY][eE][sS])
USE_BUILTIN.MesaLib!=	\
	if ${PKG_ADMIN} pmatch '${_depend_}' ${BUILTIN_PKG.MesaLib}; then \
		${ECHO} "yes";						\
	else								\
		${ECHO} "no";						\
	fi
.      endif
.    endfor
.  endif
.endif	# USE_BUILTIN.MesaLib

.if !empty(USE_BUILTIN.MesaLib:M[nN][oO])
BUILDLINK_DEPENDS.MesaLib+=	MesaLib>=6.0
.endif

.if !empty(USE_BUILTIN.MesaLib:M[yY][eE][sS])
BUILDLINK_PREFIX.MesaLib=	${X11BASE}
USE_X11=			yes
_MESA_REQD=			${_MESA_VERSION}
.endif
