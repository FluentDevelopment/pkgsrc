# $NetBSD: buildlink3.mk,v 1.4 2004/01/24 03:26:46 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBSLANG_BUILDLINK3_MK:=	${LIBSLANG_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libslang
.endif

.if !empty(LIBSLANG_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		libslang
BUILDLINK_DEPENDS.libslang+=	libslang>=1.4.9nb1
BUILDLINK_PKGSRCDIR.libslang?=	../../devel/libslang

# Debian adds a dependency on ncurses.
.  if (${OPSYS} == "Linux") && (${LOWER_VENDOR} == "debian")
.    include "../../devel/ncurses/buildlink3.mk"
.  endif
.endif	# LIBSLANG_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
