# $NetBSD: buildlink3.mk,v 1.5 2004/04/06 09:36:28 jmmv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GST_PLUGINS_BUILDLINK3_MK:=	${GST_PLUGINS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gst-plugins
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngst-plugins}
BUILDLINK_PACKAGES+=	gst-plugins

.if !empty(GST_PLUGINS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gst-plugins+=		gst-plugins>=0.8.0nb2
BUILDLINK_PKGSRCDIR.gst-plugins?=	../../multimedia/gst-plugins
.endif	# GST_PLUGINS_BUILDLINK3_MK

.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/GConf2/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../multimedia/gstreamer/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
