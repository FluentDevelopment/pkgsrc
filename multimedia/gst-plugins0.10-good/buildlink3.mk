# $NetBSD: buildlink3.mk,v 1.3 2006/04/06 06:22:25 reed Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
GST_PLUGINS0.10_GOOD_BUILDLINK3_MK:=	${GST_PLUGINS0.10_GOOD_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gst-plugins0.10-good
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngst-plugins0.10-good}
BUILDLINK_PACKAGES+=	gst-plugins0.10-good

.if !empty(GST_PLUGINS0.10_GOOD_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gst-plugins0.10-good+=	gst-plugins0.10-good>=0.10.1
BUILDLINK_ABI_DEPENDS.gst-plugins0.10-good?=	gst-plugins0.10-good>=0.10.1nb1
BUILDLINK_PKGSRCDIR.gst-plugins0.10-good?=	../../multimedia/gst-plugins0.10-good
.endif	# GST_PLUGINS0.10_GOOD_BUILDLINK3_MK

.include "../../multimedia/gstreamer0.10/buildlink3.mk"
.include "../../multimedia/gst-plugins0.10-base/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
