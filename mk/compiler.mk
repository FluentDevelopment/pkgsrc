# $NetBSD: compiler.mk,v 1.23 2003/11/12 13:13:43 grant Exp $

# This Makefile fragment implements handling for supported
# C/C++/fortran compilers.
#
# This file should NOT be included from pkg Makefiles, as it is
# automatically included by bsd.prefs.mk.
#
# The following variables are used:
#
# GCC_REQD
#	Sets the minimum required version of gcc. Packages can set
#	this if they are known to require gcc>2.8.0, which is the
#	compiler shipped with NetBSD 1.5.
#
#	Note: Be conservative when setting GCC_REQD, as lang/gcc3 is
#	known not to build on some platforms, eg. Darwin. If gcc3 is
#	required, set GCC_REQD=3.0 so that we do not try to pull in
#	lang/gcc3 unnecessarily and have it fail.
#
# USE_GCC_SHLIB
#	Indicates that a package uses GCC shared libraries, so we
#	register a runtime dependency on the compiler package.
#
# USE_GCC2
#	Always use pkgsrc gcc2 from lang/gcc. This overrides any
#	GCC_REQD setting. Must NOT be set in package Makefiles.
#
# USE_GCC3
#	Always use pkgsrc gcc3 from lang/gcc3. This overrides any
#	GCC_REQD setting. Must NOT be set in package Makefiles.
#
# USE_PKGSRC_GCC
#	Use the appropriate version of GCC from pkgsrc based on
#	GCC_REQD.
#
# USE_SUNPRO
#	Use the Sun Microsystems Inc. WorkShop/Forte/Sun ONE Studio
#	compiler collection.
#
# USE_MIPSPRO
#	Use the Silicon Graphics, Inc. MIPSpro compiler.
#
# The following variables are defined, and available for testing in
# package Makefiles:
#
# CC_VERSION
#	The compiler and version being used. For gcc, this is
#	'gcc-<version>' and the string reported by ${CC} -V | grep
#	'^cc' for others.
#
#	e.g.
#		.include "../../mk/bsd.prefs.mk"
#
#		.if !empty(CC_VERSION:Mgcc-3*)
#		...
#		.endif
#

.if !defined(COMPILER_MK)
COMPILER_MK=	# defined

# Defaults for SunPro, work around sys.mk setting CC by default to
# 'gcc'. These can be overriden by the user in /etc/mk.conf or on the
# command line.
.if defined(USE_SUNPRO) && defined(CC) && !empty(CC:Mgcc)
CC=	/opt/SUNWspro/bin/cc
CXX=	/opt/SUNWspro/bin/CC
.endif

# Do a dance to determine which version of gcc is being used, if any,
# and whether it satisfies GCC_REQD.
#
# We only pull in lang/gcc or lang/gcc3 if necessary, or if
# USE_PKGSRC_GCC is defined.
#
.if !defined(USE_SUNPRO) && !defined(USE_MIPSPRO) && \
    !defined(USE_GCC2) && !defined(USE_GCC3)

# Darwin's gcc reports "Apple Computer ... based on gcc version ...",
# so we can't just grep for ^gcc.
_CC_VERSION_STRING!=	if ${CC} -v 2>&1 | ${GREP} -q 'gcc version'; then \
				echo `${CC} -v 2>&1 | ${GREP} 'gcc version'`; \
			fi

# egcs is considered to be gcc-2.8.1.
.  if !empty(_CC_VERSION_STRING:Megcs*)
_CC_VERSION=		2.8.1
_CC_IS_GCC=		YES
.  elif !empty(_CC_VERSION_STRING:Mgcc*)
_CC_VERSION!=		${CC} -dumpversion
_CC_IS_GCC=		YES
.  endif

.  if defined(_CC_IS_GCC)
GCC_REQD?=		2.8.0
_GCC_VERSION_REQD=	gcc>=${GCC_REQD}

# packages should define USE_PKGSRC_GCC to force install and use of
# pkgsrc gcc, which defaults to gcc2.
.    if defined(USE_PKGSRC_GCC)
GCC_REQD=		2.95.3
_NEED_PKGSRC_GCC=	YES
.    else
_GCC_IN_USE=		gcc-${_CC_VERSION}
_NEED_PKGSRC_GCC!=	\
	if ${PKG_ADMIN} pmatch '${_GCC_VERSION_REQD}' ${_GCC_IN_USE}; then \
		${ECHO} "NO"; \
	else \
		${ECHO} "YES"; \
	fi
.    endif # USE_PKGSRC_GCC

.  endif # _CC_IS_GCC

.endif # !USE_MIPSPRO && !USE_SUNPRO && !USE_GCC2 && !USE_GCC3

# we default to gcc2 if all of the above determined that we need
# pkgsrc gcc.
.if defined(_NEED_PKGSRC_GCC) && ${_NEED_PKGSRC_GCC} == "YES"
.  if !empty(GCC_REQD:M3*)
USE_GCC3=		# defined
.  else
USE_GCC2=		# defined
.  endif
.endif

.if defined(USE_GCC2) && empty(_PKGSRC_DEPS:Mgcc-2*)
GCC_REQD=		2.95.3

# we need to define these early, as they are used by gcc/buildlink2.mk.
_GCC_SUBPREFIX=		gcc-2.95.3/
_GCC_ARCHDIR=		${_GCC_PREFIX}${_GCC_ARCHSUBDIR}
_GCC_PREFIX=		${LOCALBASE}/${_GCC_SUBPREFIX}
_GCC_LIBGCCDIR!=						\
  if [ -x ${_GCC_PREFIX}bin/gcc ]; then				\
    dirname `${_GCC_PREFIX}bin/gcc --print-libgcc-file-name`;	\
  else								\
    ${ECHO} not-defined;					\
  fi
_GCC_ARCHSUBDIR= \
  ${_GCC_LIBGCCDIR:S|^${BUILDLINK_PREFIX.gcc}/${_GCC_SUBPREFIX}||}

# Only pull in the pkg dependency if we're not actually building it
.  if empty(PKGPATH:Mlang/gcc)

.    if empty(USE_BUILDLINK2:M[nN][oO])
.      include "../lang/gcc/buildlink2.mk"
.    else

# Packages that link against gcc shared libraries need a full
# dependency.
.      if defined(USE_GCC_SHLIB)
DEPENDS+=		gcc>=${GCC_REQD}:../../lang/gcc
.      else
BUILD_DEPENDS+=		gcc>=${GCC_REQD}:../../lang/gcc
.      endif
.    endif	# buildlink2
.  endif	# PKGPATH != lang/gcc

.  if exists(${_GCC_PREFIX}bin/gcc)
_CC_IS_GCC=		YES
PATH:=			${_GCC_PREFIX}bin:${PATH}
CC=			${_GCC_PREFIX}bin/gcc
CPP=			${_GCC_PREFIX}bin/cpp
CXX=			${_GCC_PREFIX}bin/g++
F77=			${_GCC_PREFIX}bin/g77
PKG_FC:=		${F77}
.  endif

.elif defined(USE_GCC3) && empty(_PKGSRC_DEPS:Mgcc-3*)
GCC_REQD=		3.3

# we need to define these early, as they are used by gcc3/buildlink2.mk.
_GCC_SUBPREFIX=		gcc-3.3/
_GCC_ARCHDIR=		${_GCC_PREFIX}${_GCC_ARCHSUBDIR}
_GCC_PREFIX=		${LOCALBASE}/${_GCC_SUBPREFIX}

# Only pull in the pkg dependency if we're not actually building it
.  if empty(PKGPATH:Mlang/gcc3)

.    if empty(USE_BUILDLINK2:M[nN][oO])
.      include "../lang/gcc3/buildlink2.mk"
.    else

# Packages that link against gcc shared libraries need a full
# dependency.
.      if defined(USE_GCC_SHLIB)
DEPENDS+=		gcc3>=${GCC_REQD}:../../lang/gcc3
.      else
BUILD_DEPENDS+=		gcc3>=${GCC_REQD}:../../lang/gcc3
.      endif
.    endif	# buildlink2
.  endif	# PKGPATH != lang/gcc3

.  if exists(${_GCC_PREFIX}bin/gcc)
_GCC_LIBGCCDIR!= \
  dirname `${_GCC_PREFIX}bin/gcc --print-libgcc-file-name`
_GCC_ARCHSUBDIR= \
  ${_GCC_LIBGCCDIR:S|^${LOCALBASE}/${_GCC_SUBPREFIX}||}

_CC_IS_GCC=		YES
PATH:=			${_GCC_PREFIX}bin:${PATH}
CC=			${_GCC_PREFIX}bin/gcc
CPP=			${_GCC_PREFIX}bin/cpp
CXX=			${_GCC_PREFIX}bin/g++
F77=			${_GCC_PREFIX}bin/g77
PKG_FC:=		${F77}
.  endif
.endif	# USE_GCC3

# Ensure that the correct rpath is passed to the linker if we need to
# link against gcc shared libs.
.if (defined(USE_GCC2) || defined(USE_GCC3)) && defined(USE_GCC_SHLIB)
_GCC_LDFLAGS=		-L${_GCC_ARCHDIR} -Wl,${RPATH_FLAG}${_GCC_ARCHDIR} -L${_GCC_PREFIX}lib -Wl,${RPATH_FLAG}${_GCC_PREFIX}lib
LDFLAGS+=		${_GCC_LDFLAGS}
.endif

# CC_VERSION can be tested by package Makefiles to tweak things based
# on the compiler being used.
#
CC_VERSION?=		# empty
.if defined(_CC_IS_GCC)
.  if !defined(_CC_VERSION)
_CC_VERSION!=		if ${CC} -dumpversion > /dev/null 2>&1; then \
				${ECHO} `${CC} -dumpversion`; \
			else \
				${ECHO} ""; \
			fi
.  endif
CC_VERSION=		gcc-${_CC_VERSION}
.else
CC_VERSION!=		${CC} -V 2>&1 | ${GREP} '^cc'
.endif

# The SunPro C++ compiler doesn't support passing linker flags with
# -Wl to CC, so we make buildlink2 perform the required magic.
#
.if defined(USE_SUNPRO)
_COMPILER_LD_FLAG=		# SunPro compiler
.else
_COMPILER_LD_FLAG=	-Wl,	# GCC and others
.endif

# Pass the required flags to imake to tell it we're using gcc on
# Solaris.
#
.if ${OPSYS} == "SunOS" && defined(_CC_IS_GCC)
IMAKEOPTS+=	-DHasGcc2=YES -DHasGcc2ForCplusplus=YES
.endif

.endif	# COMPILER_MK

# XXX this test is outside if !defined(COMPILER_MK) because some
# XXX packages include bsd.prefs.mk before defining USE_BUILDLINK2.
#
# create a fake libstdc++.la if one exists in /usr/lib.
.if empty(USE_BUILDLINK2:M[nN][oO])
.  if defined(_CC_IS_GCC) && exists(/usr/lib/libstdc++.la)
.    if (!defined(BUILDLINK_TARGETS) || \
     defined(BUILDLINK_TARGETS) && empty(BUILDLINK_TARGETS:Mlibstdc++-buildlink-la))
BUILDLINK_TARGETS+=		libstdc++-buildlink-la

libstdc++-buildlink-la:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	lafile="${BUILDLINK_DIR}/lib/libstdc++.la";			\
	libpattern="/usr/lib/libstdc++.*";				\
	${BUILDLINK_FAKE_LA}
.    endif
.  endif
.endif
