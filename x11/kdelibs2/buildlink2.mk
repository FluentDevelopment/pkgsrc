# $NetBSD: buildlink2.mk,v 1.5 2002/10/10 00:11:50 jlam Exp $

.if !defined(KDELIBS2_BUILDLINK2_MK)
KDELIBS2_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_PACKAGES+=		kdelibs2
BUILDLINK_PKGBASE.kdelibs2?=	kdelibs
BUILDLINK_DEPENDS.kdelibs2?=	kdelibs>=2.2.2nb3
BUILDLINK_PKGSRCDIR.kdelibs2?=	../../x11/kdelibs2

EVAL_PREFIX+=	BUILDLINK_PREFIX.kdelibs2=kdelibs
BUILDLINK_PREFIX.kdelibs2_DEFAULT=	${X11PREFIX}
_KDELIBS2_BLNK_FILES= \
	${BUILDLINK_PLIST_CMD.kdelibs2} | ${GREP} '^\(include\|lib\)'
BUILDLINK_FILES.kdelibs2=	`${_KDELIBS2_BLNK_FILES}`

KDEDIR=				${BUILDLINK_PREFIX.kdelibs2}

BUILDLINK_DEPENDS.audiofile=	libaudiofile>=0.1.9
BUILDLINK_DEPENDS.qt2-libs=	qt2-libs>=2.3.1nb2
USE_OPENSSL_VERSION=		${OPENSSL_VERSION_096}

.include "../../audio/libaudiofile/buildlink2.mk"
.include "../../devel/pcre/buildlink2.mk"
.include "../../security/openssl/buildlink2.mk"
.include "../../x11/qt2-libs/buildlink2.mk"
.include "../../mk/ossaudio.buildlink2.mk"

.if defined(USE_CUPS) && (${USE_CUPS} == "YES")
.  include "../../print/cups/buildlink2.mk"
.endif

BUILDLINK_TARGETS+=	kdelibs2-buildlink

kdelibs2-buildlink: _BUILDLINK_USE

.endif	# KDELIBS2_BUILDLINK2_MK
