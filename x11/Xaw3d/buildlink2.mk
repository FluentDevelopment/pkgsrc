# $NetBSD: buildlink2.mk,v 1.4 2003/03/03 14:22:41 seb Exp $

.if !defined(XAW3D_BUILDLINK2_MK)
XAW3D_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		Xaw3d
BUILDLINK_DEPENDS.Xaw3d?=	Xaw3d-1.5
BUILDLINK_PKGSRCDIR.Xaw3d?=	../../x11/Xaw3d

.include "../../mk/bsd.prefs.mk"

EVAL_PREFIX+=			BUILDLINK_PREFIX.Xaw3d=Xaw3d
BUILDLINK_PREFIX.Xaw3d_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.Xaw3d=		include/X11/X11/Xaw3d/*	# for OpenWindows
BUILDLINK_FILES.Xaw3d+=		include/X11/Xaw3d/*
BUILDLINK_FILES.Xaw3d+=		lib/libXaw3d.*

BUILDLINK_TARGETS+=	Xaw3d-buildlink

LIBXAW?=	-L${BUILDLINK_PREFIX.Xaw3d}/lib				\
		-Wl,${_OPSYS_RPATH_NAME}${BUILDLINK_PREFIX.Xaw3d}/lib	\
		-lXaw3d

Xaw3d-buildlink: _BUILDLINK_USE

.endif	# XAW3D_BUILDLINK2_MK
