# $NetBSD: buildlink3.mk,v 1.7 2004/04/15 21:20:32 jmmv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GSTREAMER_BUILDLINK3_MK:=	${GSTREAMER_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gstreamer
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngstreamer}
BUILDLINK_PACKAGES+=	gstreamer

.if !empty(GSTREAMER_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gstreamer+=	gstreamer>=0.8.0nb1
BUILDLINK_PKGSRCDIR.gstreamer?=	../../multimedia/gstreamer

PRINT_PLIST_AWK+=	/^@dirrm (include|lib)\/gstreamer-0.8(\/gst)?$$/ \
				{ print "@comment in gstreamer: " $$0; next; }
.endif	# GSTREAMER_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../devel/popt/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../textproc/libxslt/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
