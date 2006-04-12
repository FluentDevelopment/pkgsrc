# $NetBSD: buildlink3.mk,v 1.5 2006/04/12 10:27:08 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
G_WRAP_BUILDLINK3_MK:=	${G_WRAP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	g-wrap
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ng-wrap}
BUILDLINK_PACKAGES+=	g-wrap

.if !empty(G_WRAP_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.g-wrap+=	g-wrap>=1.3.4nb6
BUILDLINK_API_DEPENDS.g-wrap+=	g-wrap<1.4
BUILDLINK_ABI_DEPENDS.g-wrap?=	g-wrap>=1.3.4nb7
BUILDLINK_PKGSRCDIR.g-wrap?=	../../devel/g-wrap1
.endif	# G_WRAP_BUILDLINK3_MK

.include "../../devel/glib/buildlink3.mk"
.include "../../lang/guile/buildlink3.mk"
.include "../../devel/guile-gtk/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
