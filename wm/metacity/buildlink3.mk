# $NetBSD: buildlink3.mk,v 1.3 2004/03/05 19:25:41 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
METACITY_BUILDLINK3_MK:=	${METACITY_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	metacity
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmetacity}
BUILDLINK_PACKAGES+=	metacity

.if !empty(METACITY_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.metacity+=	metacity>=2.6.3nb1
BUILDLINK_PKGSRCDIR.metacity?=	../../wm/metacity

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/libglade2/buildlink3.mk"
.include "../../devel/pango/buildlink3.mk"
.include "../../net/ORBit2/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/startup-notification/buildlink3.mk"

.endif	# METACITY_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
