# $NetBSD: buildlink2.mk,v 1.15 2004/02/12 02:35:06 jlam Exp $

.if !defined(BINUTILS_BUILDLINK2_MK)
BINUTILS_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_DEPENDS.binutils?=		binutils>=2.14.0
BUILDLINK_PKGSRCDIR.binutils?=		../../devel/binutils
BUILDLINK_DEPMETHOD.binutils?=		build

# These versions of NetBSD didn't have a toolchain that could be used in
# place of modern binutils and will need this package
#
_INCOMPAT_BINUTILS=	NetBSD-0.*-* NetBSD-1.[01234]*-*
_INCOMPAT_BINUTILS+=	NetBSD-1.5.*-* NetBSD-1.5[A-X]-*
#
# XXX: _INCOMPAT_BINUTILS settings for other operating systems possibly
# XXX: needed here
#
_BUILTIN_BINUTILS=	YES
.for _pattern_ in ${_INCOMPAT_BINUTILS} ${INCOMPAT_BINUTILS}
.  if !empty(MACHINE_PLATFORM:M${_pattern_})
_BUILTIN_BINUTILS=	NO
.  endif
.endfor

.if ${_BUILTIN_BINUTILS} == "YES"
_NEED_BINUTILS=		NO
.else
_NEED_BINUTILS=		YES
.endif

.if !empty(PREFER_NATIVE:M[yY][eE][sS]) && \
    ${_BUILTIN_BINUTILS} == "YES"
_NEED_BINUTILS=		NO
.endif
.if !empty(PREFER_PKGSRC:M[yY][eE][sS])
_NEED_BINUTILS=		YES
.endif
.if !empty(PREFER_NATIVE:Mbinutils) && \
    ${_BUILTIN_BINUTILS} == "YES"
_NEED_BINUTILS=		NO
.endif
.if !empty(PREFER_PKGSRC:Mbinutils)
_NEED_BINUTILS=		YES
.endif

.if defined(USE_BINUTILS)
_NEED_BINUTILS=		YES
.endif

.if ${_NEED_BINUTILS} == "YES"
BUILDLINK_PACKAGES+=		binutils
BUILDLINK_PREFIX.binutils=	${LOCALBASE}

PATH:=	${BUILDLINK_PREFIX.binutils}/bin:${PATH}

AR=	${BUILDLINK_PREFIX.binutils}/bin/ar
AS=	${BUILDLINK_PREFIX.binutils}/bin/as
LD=	${BUILDLINK_PREFIX.binutils}/bin/ld
NM=	${BUILDLINK_PREFIX.binutils}/bin/nm
RANLIB=	${BUILDLINK_PREFIX.binutils}/bin/ranlib

BUILDLINK_TARGETS+=	binutils-buildlink
.endif	# _NEED_BINUTILS == YES

BUILDLINK_FILES.binutils+=	include/ansidecl.h
BUILDLINK_FILES.binutils+=	include/bfd.h
BUILDLINK_FILES.binutils+=	include/bfdlink.h
BUILDLINK_FILES.binutils+=	include/dis-asm.h
BUILDLINK_FILES.binutils+=	include/symcat.h
BUILDLINK_FILES.binutils+=	lib/libbfd.*
BUILDLINK_FILES.binutils+=	lib/libiberty.*
BUILDLINK_FILES.binutils+=	lib/libopcodes.*

binutils-buildlink: _BUILDLINK_USE

.endif	# BINUTILS_BUILDLINK2_MK
