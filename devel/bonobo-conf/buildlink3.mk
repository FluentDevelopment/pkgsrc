# $NetBSD: buildlink3.mk,v 1.4 2004/12/28 23:18:15 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
BONOBO_CONF_BUILDLINK3_MK:=	${BONOBO_CONF_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	bonobo-conf
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nbonobo-conf}
BUILDLINK_PACKAGES+=	bonobo-conf

.if !empty(BONOBO_CONF_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.bonobo-conf+=	bonobo-conf>=0.14nb10
BUILDLINK_RECOMMENDED.bonobo-conf+=	bonobo-conf>=0.14nb11
BUILDLINK_PKGSRCDIR.bonobo-conf?=	../../devel/bonobo-conf
.endif	# BONOBO_CONF_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/bonobo/buildlink3.mk"
.include "../../devel/GConf/buildlink3.mk"
.include "../../devel/popt/buildlink3.mk"
.include "../../devel/oaf/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
