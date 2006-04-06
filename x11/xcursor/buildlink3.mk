# $NetBSD: buildlink3.mk,v 1.17 2006/04/06 06:23:04 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
XCURSOR_BUILDLINK3_MK:=	${XCURSOR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xcursor
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxcursor}
BUILDLINK_PACKAGES+=	xcursor

.if !empty(XCURSOR_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.xcursor+=	xcursor>=1.0
BUILDLINK_ABI_DEPENDS.xcursor+=	xcursor>=1.1.2nb1
BUILDLINK_PKGSRCDIR.xcursor?=	../../x11/xcursor
.endif	# XCURSOR_BUILDLINK3_MK

# Xfixes/buildlink3.mk is included by xcursor/builtin.mk
#.include "../../x11/Xfixes/buildlink3.mk"

.include "../../x11/Xrender/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
