# $NetBSD: buildlink3.mk,v 1.7 2006/04/27 03:19:35 wulf Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
USRP_BUILDLINK3_MK:=	${USRP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	usrp
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nusrp}
BUILDLINK_PACKAGES+=	usrp

.if !empty(USRP_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.usrp=	usrp>=0.12
BUILDLINK_PKGSRCDIR.usrp?=	../../ham/usrp
.endif	# USRP_BUILDLINK3_MK

.include "../../ham/gnuradio-core/buildlink3.mk"
.include "../../devel/libusb/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
