# $NetBSD: buildlink3.mk,v 1.8 2004/05/11 17:36:25 recht Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CAIRO_BUILDLINK3_MK:=	${CAIRO_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cairo
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncairo}
BUILDLINK_PACKAGES+=	cairo

.if !empty(CAIRO_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cairo+=	cairo>=0.1.23
BUILDLINK_PKGSRCDIR.cairo?=	../../graphics/cairo

BUILDLINK_DEPENDS.freetype2+=	freetype2>=2.1.5
BUILDLINK_DEPENDS.Xft2+=	Xft2>=2.1.2
BUILDLINK_DEPENDS.Xrender+=	Xrender>=0.8
.endif	# CAIRO_BUILDLINK3_MK

.include "../../fonts/Xft2/buildlink3.mk"
.include "../../graphics/freetype2/buildlink3.mk"
.include "../../graphics/glitz/buildlink3.mk"
.include "../../graphics/libpixman/buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../x11/Xrender/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
