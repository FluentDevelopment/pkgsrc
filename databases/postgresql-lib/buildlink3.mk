# $NetBSD: buildlink3.mk,v 1.1 2004/01/03 23:06:43 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
POSTGRESQL_LIB_BUILDLINK3_MK:=	${POSTGRESQL_LIB_BUILDLINK3_MK}+

.if !empty(POSTGRESQL_LIB_BUILDLINK3_MK:M\+)
BUILDLINK_DEPENDS.postgresql-lib?=	postgresql-lib>=7.3.1
BUILDLINK_PKGSRCDIR.postgresql-lib?=	../../databases/postgresql-lib
BUILDLINK_INCDIRS.postgresql-lib?=	include/postgresql
.endif	# POSTGRESQL_LIB_BUILDLINK3_MK

.if !empty(BUILDLINK_DEPTH:M\+)
BUILDLINK_DEPENDS+=	postgresql-lib
.endif

.if !empty(POSTGRESQL_LIB_BUILDLINK3_MK:M\+)
BUILDLINK_PACKAGES+=	postgresql-lib

.  include "../../security/openssl/buildlink3.mk"
.endif	# POSTGRESQL_LIB_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
