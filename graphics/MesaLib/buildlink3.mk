# $NetBSD: buildlink3.mk,v 1.8 2003/09/30 10:18:57 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
MESALIB_BUILDLINK3_MK:=	${MESALIB_BUILDLINK3_MK}+

.if !empty(MESALIB_BUILDLINK3_MK:M\+)
.  include "../../mk/bsd.prefs.mk"

MESA_REQD?=		3.4.2

BUILDLINK_DEPENDS.MesaLib?=	MesaLib>=${MESA_REQD}
BUILDLINK_PKGSRCDIR.MesaLib?=	../../graphics/MesaLib
.endif	# MESALIB_BUILDLINK3_MK

BUILDLINK_CHECK_BUILTIN.MesaLib?=	NO

_GL_GLX_H=	${X11BASE}/include/GL/glx.h
_X11_TMPL=	${X11BASE}/lib/X11/config/X11.tmpl

.if !defined(BUILDLINK_IS_BUILTIN.MesaLib)
BUILDLINK_IS_BUILTIN.MesaLib=	NO
.  if exists(${_GL_GLX_H}) && exists(${_X11_TMPL})
BUILDLINK_IS_BUILTIN.MesaLib!=						\
	if ${GREP} -q BuildGLXLibrary ${_X11_TMPL}; then		\
		${ECHO} YES;						\
	else								\
		${ECHO} NO;						\
	fi
.  endif
MAKEFLAGS+=	BUILDLINK_IS_BUILTIN.MesaLib=${BUILDLINK_IS_BUILTIN.MesaLib}
.endif

.if !empty(BUILDLINK_CHECK_BUILTIN.MesaLib:M[yY][eE][sS])
_NEED_MESALIB=	NO
.endif

.if !defined(_NEED_MESALIB)
.  if !empty(BUILDLINK_IS_BUILTIN.MesaLib:M[nN][oO])
_NEED_MESALIB=	YES
.  else
#
# Create an appropriate package name for the built-in Mesa/GLX distributed
# with the system.  This package name can be used to check against
# BUILDLINK_DEPENDS.<pkg> to see if we need to install the pkgsrc version
# or if the built-in one is sufficient.
#
.    include "../../graphics/Mesa/version.mk"
_MESALIB_PKG=		MesaLib-${_MESA_VERSION}
_MESALIB_DEPENDS=	${BUILDLINK_DEPENDS.MesaLib}
_NEED_MESALIB!=	\
	if ${PKG_ADMIN} pmatch '${_MESALIB_DEPENDS}' ${_MESALIB_PKG}; then \
		${ECHO} "NO";						\
	else								\
		${ECHO} "YES";						\
	fi
.  endif
MAKEFLAGS+=	_NEED_MESALIB="${_NEED_MESALIB}"
.endif	# _NEED_MESALIB

.if ${_NEED_MESALIB} == "YES"
#
# If we depend on the package, depend on the latest version with a library
# major number bump.
#
BUILDLINK_DEPENDS.MesaLib=	MesaLib>=5.0
.  if !empty(BUILDLINK_DEPTH:M\+)
BUILDLINK_DEPENDS+=		MesaLib
.  endif
.endif

.if !empty(MESALIB_BUILDLINK3_MK:M\+)
.  if ${_NEED_MESALIB} == "YES"
BUILDLINK_PACKAGES+=		MesaLib
BUILDLINK_CPPFLAGS.MesaLib=	-DGLX_GLXEXT_LEGACY
.  else
BUILDLINK_PREFIX.MesaLib=	${X11BASE}
.  endif
.endif	# MESALIB_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
