# $NetBSD: buildlink2.mk,v 1.3 2002/08/29 17:19:25 jlam Exp $

.if !defined(TCL_BUILDLINK2_MK)
TCL_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		tcl
BUILDLINK_DEPENDS.tcl?=		tcl>=8.3.4
BUILDLINK_PKGSRCDIR.tcl?=	../../lang/tcl

EVAL_PREFIX+=		BUILDLINK_PREFIX.tcl=tcl
BUILDLINK_PREFIX.tcl_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.tcl=	include/tcl.h
BUILDLINK_FILES.tcl+=	include/tclDecls.h
BUILDLINK_FILES.tcl+=	include/tclPlatDecls.h
BUILDLINK_FILES.tcl+=	include/tcl/*/*.h
BUILDLINK_FILES.tcl+=	lib/libtcl83.*
BUILDLINK_FILES.tcl+=	lib/libtclstub83.*

BUILDLINK_TARGETS+=	tcl-buildlink

tcl-buildlink: _BUILDLINK_USE

TCLCONFIG_SH?=		${BUILDLINK_PREFIX.tcl}/lib/tclConfig.sh

.endif	# TCL_BUILDLINK2_MK
