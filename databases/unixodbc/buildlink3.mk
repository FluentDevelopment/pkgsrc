# $NetBSD: buildlink3.mk,v 1.2 2004/10/03 00:13:24 tv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
UNIXODBC_BUILDLINK3_MK:=	${UNIXODBC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	unixodbc
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nunixodbc}
BUILDLINK_PACKAGES+=	unixodbc

.if !empty(UNIXODBC_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.unixodbc+=	unixodbc>=2.0.11nb1
BUILDLINK_RECOMMENDED.unixodbc+=	unixodbc>=2.0.11nb3
BUILDLINK_PKGSRCDIR.unixodbc?=	../../databases/unixodbc
.endif	# UNIXODBC_BUILDLINK3_MK

.include "../../devel/readline/buildlink3.mk"
.include "../../devel/libtool/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
