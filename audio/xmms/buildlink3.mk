# $NetBSD: buildlink3.mk,v 1.6 2006/04/06 06:21:37 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
XMMS_BUILDLINK3_MK:=	${XMMS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xmms
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxmms}
BUILDLINK_PACKAGES+=	xmms

.if !empty(XMMS_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.xmms+=	xmms>=1.2.7nb10
BUILDLINK_ABI_DEPENDS.xmms?=	xmms>=1.2.10nb6
BUILDLINK_PKGSRCDIR.xmms?=	../../audio/xmms
.endif	# XMMS_BUILDLINK3_MK

PTHREAD_OPTS+=	require

.include "../../audio/libmikmod/buildlink3.mk"
.include "../../audio/libvorbis/buildlink3.mk"
.include "../../converters/libiconv/buildlink3.mk"
.include "../../graphics/MesaLib/buildlink3.mk"
.include "../../textproc/libxml/buildlink3.mk"
.include "../../x11/gtk/buildlink3.mk"

.include "../../mk/pthread.buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
