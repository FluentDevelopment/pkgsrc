# $NetBSD: buildlink2.mk,v 1.15 2003/08/01 15:31:09 drochner Exp $

.if !defined(QT3_LIBS_BUILDLINK2_MK)
QT3_LIBS_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		qt3-libs
BUILDLINK_DEPENDS.qt3-libs?=	qt3-libs>=3.1.2nb2
BUILDLINK_PKGSRCDIR.qt3-libs?=	../../x11/qt3-libs

EVAL_PREFIX+=	BUILDLINK_PREFIX.qt3-libs=qt3-libs
BUILDLINK_PREFIX.qt3-libs_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.qt3-libs+=	qt3/include/*.h
BUILDLINK_FILES.qt3-libs+=	qt3/include/private/*.h
BUILDLINK_FILES.qt3-libs+=	qt3/lib/libqt-mt.*

QTDIR=		${BUILDLINK_PREFIX.qt3-libs}/qt3

BUILDLINK_CPPFLAGS.qt3-libs=	-I${QTDIR}/include
BUILDLINK_LDFLAGS.qt3-libs=	-L${QTDIR}/lib -Wl,${RPATH_FLAG}${QTDIR}/lib
FIX_RPATH+=			BUILDLINK_LDFLAGS.qt3-libs

PTHREAD_OPTS+=	require

.include "../../devel/zlib/buildlink2.mk"
.include "../../fonts/Xft2/buildlink2.mk"
.include "../../graphics/MesaLib/buildlink2.mk"
.include "../../graphics/freetype2/buildlink2.mk"
.include "../../graphics/glu/buildlink2.mk"
.include "../../graphics/jpeg/buildlink2.mk"
.include "../../graphics/mng/buildlink2.mk"
.include "../../graphics/png/buildlink2.mk"
.include "../../mk/pthread.buildlink2.mk"

CONFIGURE_ENV+=		MOC="${QTDIR}/bin/moc"
MAKE_ENV+=		MOC="${QTDIR}/bin/moc"
LDFLAGS+=		-Wl,${RPATH_FLAG}${QTDIR}/lib

.if !defined(BUILD_QT3)
CONFIGURE_ENV+=		QTDIR="${QTDIR}"
MAKE_ENV+=		QTDIR="${QTDIR}"
.endif

BUILDLINK_TARGETS+=	qt3-libs-buildlink

qt3-libs-buildlink: _BUILDLINK_USE

.endif	# QT3_LIBS_BUILDLINK2_MK
