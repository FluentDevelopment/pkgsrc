# $NetBSD: buildlink3.mk,v 1.1 2004/03/23 06:13:30 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
CYRUS_SASL_BUILDLINK3_MK:=	${CYRUS_SASL_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cyrus-sasl
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncyrus-sasl}
BUILDLINK_PACKAGES+=	cyrus-sasl

.if !empty(CYRUS_SASL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cyrus-sasl+=		cyrus-sasl>=1.5.27nb3
BUILDLINK_PKGSRCDIR.cyrus-sasl?=	../../security/cyrus-sasl
.endif	# CYRUS_SASL_BUILDLINK3_MK

.if defined(USE_PAM)
.  include "../../security/PAM/buildlink3.mk"
.endif

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
