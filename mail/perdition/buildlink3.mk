# $NetBSD: buildlink3.mk,v 1.2 2006/02/05 23:09:57 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PERDITION_BUILDLINK3_MK:=	${PERDITION_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	perdition
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nperdition}
BUILDLINK_PACKAGES+=	perdition

.if !empty(PERDITION_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.perdition+=	perdition>=1.17
BUILDLINK_RECOMMENDED.perdition?=	perdition>=1.17nb1
BUILDLINK_PKGSRCDIR.perdition?=	../../mail/perdition
.endif	# PERDITION_BUILDLINK3_MK

# The following are included in Makefile.common for "configure"'s sake.
#.include "../../devel/popt/buildlink3.mk"
#.include "../../devel/vanessa_adt/buildlink3.mk"
#.include "../../devel/vanessa_logger/buildlink3.mk"
#.include "../../devel/vanessa_socket/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
