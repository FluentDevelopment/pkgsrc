# $NetBSD: buildlink3.mk,v 1.9 2006/04/12 10:27:33 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GSASL_BUILDLINK3_MK:=	${GSASL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gsasl
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngsasl}
BUILDLINK_PACKAGES+=	gsasl

.if !empty(GSASL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gsasl+=	gsasl>=0.2.3
BUILDLINK_ABI_DEPENDS.gsasl?=	gsasl>=0.2.5nb1
BUILDLINK_PKGSRCDIR.gsasl?=	../../security/gsasl
.endif	# GSASL_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/libidn/buildlink3.mk"
.include "../../devel/libntlm/buildlink3.mk"
.include "../../security/gss/buildlink3.mk"
.include "../../security/libgcrypt/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
