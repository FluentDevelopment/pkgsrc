# $NetBSD: buildlink3.mk,v 1.5 2006/04/06 06:21:57 reed Exp $
#
# This file was created automatically using createbuildlink-3.5.

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
VANESSA_SOCKET_BUILDLINK3_MK:=	${VANESSA_SOCKET_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	vanessa_socket
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nvanessa_socket}
BUILDLINK_PACKAGES+=	vanessa_socket

.if !empty(VANESSA_SOCKET_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.vanessa_socket+=	vanessa_socket>=0.0.7nb2
BUILDLINK_ABI_DEPENDS.vanessa_socket?=	vanessa_socket>=0.0.7nb3
BUILDLINK_PKGSRCDIR.vanessa_socket?=	../../devel/vanessa_socket
.endif	# VANESSA_SOCKET_BUILDLINK3_MK

.include "../../devel/popt/buildlink3.mk"
.include "../../devel/vanessa_logger/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
