# $NetBSD: buildlink3.mk,v 1.2 2004/03/05 19:25:38 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
MJPEGTOOLS_BUILDLINK3_MK:=	${MJPEGTOOLS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	mjpegtools
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmjpegtools}
BUILDLINK_PACKAGES+=	mjpegtools

.if !empty(MJPEGTOOLS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.mjpegtools+=		mjpegtools>=1.6.1.90nb3
BUILDLINK_PKGSRCDIR.mjpegtools?=	../../multimedia/mjpegtools

.include "../../audio/lame/buildlink3.mk"
.include "../../devel/SDL/buildlink3.mk"
.include "../../graphics/ImageMagick/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"

.endif	# MJPEGTOOLS_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
