# $NetBSD: buildlink3.mk,v 1.2 2004/03/05 19:25:41 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
AP_PERL_BUILDLINK3_MK:=	${AP_PERL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	ap-perl
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nap-perl}
BUILDLINK_PACKAGES+=	ap-perl

.if !empty(AP_PERL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.ap-perl+=	ap-perl>=1.25nb1
BUILDLINK_PKGSRCDIR.ap-perl?=	../../www/ap-perl

BUILDLINK_FILES.ap-perl+=	lib/httpd/mod_perl.*
BUILDLINK_FILES.ap-perl+=	\
	${PERL5_SITEARCH:S/^${BUILDLINK_PREFIX.perl}\///}/auto/Apache/include/*
BUILDLINK_FILES.ap-perl+=	\
	${PERL5_SITEARCH:S/^${BUILDLINK_PREFIX.perl}\///}/auto/Apache/include/modules/perl/*

.include "../../www/apache/buildlink3.mk"

.endif	# AP_PERL_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
