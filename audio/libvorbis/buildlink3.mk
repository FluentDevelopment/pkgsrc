# $NetBSD: buildlink3.mk,v 1.5 2004/04/12 23:15:01 salo Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBVORBIS_BUILDLINK3_MK:=	${LIBVORBIS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libvorbis
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibvorbis}
BUILDLINK_PACKAGES+=	libvorbis

.if !empty(LIBVORBIS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libvorbis+=	libvorbis>=1.0.1
BUILDLINK_PKGSRCDIR.libvorbis?=	../../audio/libvorbis
.endif	# LIBVORBIS_BUILDLINK3_MK

.include "../../multimedia/libogg/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
