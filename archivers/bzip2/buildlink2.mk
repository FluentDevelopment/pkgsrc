# $NetBSD: buildlink2.mk,v 1.3 2003/02/04 18:40:07 jlam Exp $

.if !defined(BZIP2_BUILDLINK2_MK)
BZIP2_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_DEPENDS.bzip2?=	bzip2>=1.0.1
BUILDLINK_PKGSRCDIR.bzip2?=	../../archivers/bzip2

.if defined(USE_BZIP2)
_NEED_BZIP2=		YES
.else
.  if exists(/usr/include/bzlib.h)
#
# Recent versions of the libbz2 API prefix all functions with "BZ2_".
#
_BUILTIN_BZIP2!=	${EGREP} -c "BZ2_" /usr/include/bzlib.h || ${TRUE}
.  else
_BUILTIN_BZIP2=		0
.  endif
.  if ${_BUILTIN_BZIP2} == "0"
_NEED_BZIP2=		YES
.  else
_NEED_BZIP2=		NO
.  endif
#
# This catch-all for SunOS is probably too broad, but better to err on
# the safe side.  We can narrow down the match when we have better
# information.
#
_INCOMPAT_BZIP2=	SunOS-*-*
INCOMPAT_BZIP2?=	# empty
.  for _pattern_ in ${_INCOMPAT_BZIP2} ${INCOMPAT_BZIP2}
.    if !empty(MACHINE_PLATFORM:M${_pattern_})
_NEED_BZIP2=		YES
.    endif
.  endfor
.endif

.if ${_NEED_BZIP2} == "YES"
BUILDLINK_PACKAGES+=		bzip2
EVAL_PREFIX+=			BUILDLINK_PREFIX.bzip2=bzip2
BUILDLINK_PREFIX.bzip2_DEFAULT=	${LOCALBASE}
_BLNK_BZ2_LDFLAGS=		-L${BUILDLINK_PREFIX.bzip2}/lib -lbz2
.else
BUILDLINK_PREFIX.bzip2=		/usr
_BLNK_BZ2_LDFLAGS=		-lbz2
.endif

LIBTOOL_ARCHIVE_UNTRANSFORM_SED+= \
	-e "s|${BUILDLINK_PREFIX.bzip2}/lib/libbz2.la|${_BLNK_BZ2_LDFLAGS}|g" \
	-e "s|${LOCALBASE}/lib/libbz2.la|${_BLNK_BZ2_LDFLAGS}|g"

BUILDLINK_FILES.bzip2=		include/bzlib.h
BUILDLINK_FILES.bzip2+=		lib/libbz2.*

BUILDLINK_TARGETS+=		bzip2-buildlink
BUILDLINK_TARGETS+=		bzip2-libbz2-la

bzip2-libbz2-la:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	lafile="${BUILDLINK_DIR}/lib/libbz2.la";			\
	libpattern="${BUILDLINK_PREFIX.bzip2}/lib/libbz2.*";		\
	${BUILDLINK_FAKE_LA}

bzip2-buildlink: _BUILDLINK_USE

.endif	# BZIP2_BUILDLINK2_MK
