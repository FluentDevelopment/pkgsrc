# $NetBSD: buildlink2.mk,v 1.7 2002/10/16 22:07:47 jlam Exp $

.if !defined(GETTEXT_BUILDLINK2_MK)
GETTEXT_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

GETTEXT_REQD?=			0.10.35nb1
BUILDLINK_DEPENDS.gettext?=	gettext-lib>=${GETTEXT_REQD}
BUILDLINK_PKGSRCDIR.gettext?=	../../devel/gettext-lib

.if defined(USE_GNU_GETTEXT)
_NEED_GNU_GETTEXT=	YES
.else
_BLNK_LIBINTL_LIST!=         ${ECHO} /usr/lib/libintl.*
.  if exists(/usr/include/libintl.h) && \
      (${_BLNK_LIBINTL_LIST} != "/usr/lib/libintl.*")
#
# Consider the base system libintl to be gettext-lib-0.10.35nb1.
#
# XXX This isn't correct on Linux systems, as it may cause the installation
# XXX of the pkgsrc gettext-lib even if the system one is the latest
# XXX version.
#
_GETTEXT_PKG=		gettext-lib-0.10.35nb1
_GETTEXT_DEPENDS=	${BUILDLINK_DEPENDS.gettext}
_NEED_GNU_GETTEXT!= \
	if ${PKG_ADMIN} pmatch '${_GETTEXT_DEPENDS}' ${_GETTEXT_PKG}; then \
		${ECHO} "NO";						\
	else								\
		${ECHO} "YES";						\
	fi
.  else
_NEED_GNU_GETTEXT=	YES
.  endif
#
# Solaris has broken (for the purposes of pkgsrc) version of zlib and
# gettext.
#
_INCOMPAT_GETTEXT=	SunOS-*-*
INCOMPAT_GETTEXT?=	# empty
.  for _pattern_ in ${_INCOMPAT_GETTEXT} ${INCOMPAT_GETTEXT}
.    if !empty(MACHINE_PLATFORM:M${_pattern_})
_NEED_GNU_GETTEXT=	YES
.    endif
.  endfor
.endif

.if ${_NEED_GNU_GETTEXT} == "YES"
BUILDLINK_PACKAGES+=			gettext
EVAL_PREFIX+=	BUILDLINK_PREFIX.gettext=gettext-lib
BUILDLINK_PREFIX.gettext_DEFAULT=	${LOCALBASE}
.else
BUILDLINK_PREFIX.gettext=	/usr
.endif

BUILDLINK_FILES.gettext=	include/libintl.h
BUILDLINK_FILES.gettext+=	lib/libintl.*

BUILDLINK_TARGETS+=		gettext-buildlink
BUILDLINK_TARGETS+=		gettext-libintl-la

# Add -lintl to LIBS in CONFIGURE_ENV to work around broken gettext.m4:
# gettext.m4 does not add -lintl where it should, and the resulting
# configure script fails to detect if libintl.a is the genuine GNU gettext
# or not.
#
_BLNK_INCINTL=		# empty
_BLNK_LIBINTL=		# empty
.if ${_NEED_GNU_GETTEXT} == "YES"
_BLNK_INCINTL+=		-I${BUILDLINK_PREFIX.gettext}/include
_BLNK_LIBINTL+=		-L${BUILDLINK_PREFIX.gettext}/lib
_BLNK_LIBINTL+=		-Wl,-R${BUILDLINK_PREFIX.gettext}/lib
.endif
_BLNK_LIBINTL+=	-lintl
.if defined(GNU_CONFIGURE)
LIBS+=			${_BLNK_LIBINTL}
CONFIGURE_ENV+=		INTLLIBS="${_BLNK_LIBINTL}"
.  if ${_NEED_GNU_GETTEXT} == "NO"
#CONFIGURE_ENV+=	INCINTL="${_BLNK_INCINTL}"
#CONFIGURE_ENV+=	LIBINTL="${_BLNK_LIBINTL}"
#CONFIGURE_ENV+=	gt_cv_func_gnugettext_libintl="yes"
CONFIGURE_ENV+=		gt_cv_func_gnugettext1_libintl="yes"
.  endif
.endif

.if ${_NEED_GNU_GETTEXT} == "NO"
LIBTOOL_ARCHIVE_UNTRANSFORM_SED+= \
	-e "s|${BUILDLINK_PREFIX.gettext}/lib/libintl.la|-L${BUILDLINK_PREFIX.gettext}/lib -lintl|g" \
	-e "s|${LOCALBASE}/lib/libintl.la|-L${BUILDLINK_PREFIX.gettext}/lib -lintl|g"
.endif

gettext-buildlink: _BUILDLINK_USE

gettext-libintl-la:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	lafile="${BUILDLINK_DIR}/lib/libintl.la";			\
	libpattern="${BUILDLINK_PREFIX.gettext}/lib/libintl.*";		\
	${BUILDLINK_FAKE_LA}

.endif	# GETTEXT_BUILDLINK2_MK
