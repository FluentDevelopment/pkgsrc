# $NetBSD: buildlink2.mk,v 1.18 2004/02/02 12:19:10 jlam Exp $

# Do not directly include this file in package Makefiles. It is
# automatically included when required based on USE_GCC2.

.if !defined(GCC2_BUILDLINK2_MK)
GCC2_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_PACKAGES+=		gcc
BUILDLINK_DEPENDS.gcc?=		gcc>=${_GCC_REQD}
BUILDLINK_PKGSRCDIR.gcc?=	../../lang/gcc
#
# Packages that link against shared gcc libraries need a full
# dependency.
#
.if defined(USE_GCC_SHLIB)
BUILDLINK_DEPMETHOD.gcc+=	full
.else
BUILDLINK_DEPMETHOD.gcc?=	build
.endif

BUILDLINK_PREFIX.gcc=	${LOCALBASE}
BUILDLINK_WRAPPER_ENV+=	\
	COMPILER_PATH="${BUILDLINK_DIR}/bin"; export COMPILER_PATH

# These files are from gcc>=2.95.3.
BUILDLINK_FILES.gcc=	${_GCC_SUBPREFIX}include/g++-3/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}include/g++-3/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/gcc-lib/*/*/include/*/*/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/gcc-lib/*/*/include/*/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/gcc-lib/*/*/include/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/gcc-lib/*/*/include/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/gcc-lib/*/*/lib*.*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/gcc-lib/*/*/specs
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${MACHINE_GNU_PLATFORM}/include/*/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}${MACHINE_GNU_PLATFORM}/include/*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/libiberty.*
BUILDLINK_FILES.gcc+=	${_GCC_SUBPREFIX}lib/libstdc++.*

BUILDLINK_TARGETS+=	gcc-buildlink
BUILDLINK_TARGETS+=	libstdc++-buildlink-la

gcc-buildlink: _BUILDLINK_USE

libstdc++-buildlink-la:               
	${_PKG_SILENT}${_PKG_DEBUG}					\
	lafile="${BUILDLINK_DIR}/lib/libstdc++.la";			\
	libpattern="/usr/lib/libstdc++.*";				\
	${BUILDLINK_FAKE_LA}

.endif	# GCC2_BUILDLINK2_MK
