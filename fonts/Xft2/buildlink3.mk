# $NetBSD: buildlink3.mk,v 1.12 2004/03/18 09:12:11 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
XFT2_BUILDLINK3_MK:=	${XFT2_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=		Xft2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NXft2}
BUILDLINK_PACKAGES+=	Xft2

.if !empty(XFT2_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.Xft2+=	Xft2>=2.1
BUILDLINK_PKGSRCDIR.Xft2?=	../../fonts/Xft2
.endif	# XFT2_BUILDLINK3_MK

.include "../../fonts/fontconfig/buildlink3.mk"
.include "../../x11/Xrender/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
