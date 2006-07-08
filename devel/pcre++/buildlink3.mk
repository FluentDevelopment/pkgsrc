# $NetBSD: buildlink3.mk,v 1.4 2006/07/08 22:39:13 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PCRE++_BUILDLINK3_MK:=	${PCRE++_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pcrexx
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npcrexx}
BUILDLINK_PACKAGES+=	pcrexx
BUILDLINK_ORDER+=	pcrexx

.if !empty(PCRE++_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pcrexx+=	pcre++>=0.9.5
BUILDLINK_PKGSRCDIR.pcrexx?=	../../devel/pcre++
.endif	# PCRE++_BUILDLINK3_MK

.include "../../devel/pcre/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
