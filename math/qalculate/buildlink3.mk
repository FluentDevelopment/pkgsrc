# $NetBSD: buildlink3.mk,v 1.5 2006/02/05 23:10:04 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
QALCULATE_BUILDLINK3_MK:=	${QALCULATE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	qalculate
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nqalculate}
BUILDLINK_PACKAGES+=	qalculate

.if !empty(QALCULATE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.qalculate+=	qalculate>=0.8.2
BUILDLINK_RECOMMENDED.qalculate?=	qalculate>=0.8.2nb2
BUILDLINK_PKGSRCDIR.qalculate?=	../../math/qalculate
.endif	# QALCULATE_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"
.include "../../math/cln/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
