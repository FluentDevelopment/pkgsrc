# $NetBSD: buildlink3.mk,v 1.3 2004/02/05 03:45:13 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GCC_BUILDLINK3_MK:=	${GCC_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gcc
.endif

.if !empty(GCC_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		gcc
BUILDLINK_DEPENDS.gcc+=		gcc>=${_GCC_REQD}
BUILDLINK_PKGSRCDIR.gcc?=	../../lang/gcc
BUILDLINK_LIBDIRS.gcc?=		\
	lib ${_GCC_ARCHDIR:S/^${BUILDLINK_PREFIX.gcc}\///}

# Packages that link against shared libraries need a full dependency.
.  if defined(USE_GCC_SHLIB)
BUILDLINK_DEPMETHOD.gcc+=	full
.  else
BUILDLINK_DEPMETHOD.gcc?=	build
.  endif
.endif	# GCC_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
