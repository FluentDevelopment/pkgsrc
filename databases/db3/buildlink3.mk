# $NetBSD: buildlink3.mk,v 1.11 2004/05/13 20:23:21 kristerw Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
DB3_BUILDLINK3_MK:=	${DB3_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	db3
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ndb3}
BUILDLINK_PACKAGES+=	db3

.if !empty(DB3_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.db3+=		db3>=2.9.2
BUILDLINK_PKGSRCDIR.db3?=	../../databases/db3
BUILDLINK_INCDIRS.db3?=		include/db3
BUILDLINK_TRANSFORM+=		l:db-3:db3
USE_DB185?=			yes
.  if !empty(USE_DB185:M[yY][eE][sS])
BUILDLINK_TRANSFORM+=		l:db:db3
.  endif
.endif	# DB3_BUILDLINK3_MK

.include "../../mk/pthread.buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
