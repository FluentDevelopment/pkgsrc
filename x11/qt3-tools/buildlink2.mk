# $NetBSD: buildlink2.mk,v 1.8 2003/03/18 08:36:26 skrll Exp $

.if !defined(QT3_TOOLS_BUILDLINK2_MK)
QT3_TOOLS_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		qt3-tools
BUILDLINK_DEPENDS.qt3-tools?=	qt3-tools>=3.1.2
BUILDLINK_PKGSRCDIR.qt3-tools?=	../../x11/qt3-tools

EVAL_PREFIX+=			BUILDLINK_PREFIX.qt3-tools=qt3-tools
BUILDLINK_PREFIX.qt3-tools=	${X11PREFIX}
BUILDLINK_FILES.qt3-tools+=	qt3/lib/libeditor.*
BUILDLINK_FILES.qt3-tools+=	qt3/lib/libqui.*

.include "../../x11/qt3-libs/buildlink2.mk"

CONFIGURE_ENV+=			UIC="${QTDIR}/bin/uic"
MAKE_ENV+=			UIC="${QTDIR}/bin/uic"

BUILDLINK_TARGETS+=	qt3-tools-buildlink

qt3-tools-buildlink: _BUILDLINK_USE

.endif	# QT3_TOOLS_BUILDLINK2_MK
