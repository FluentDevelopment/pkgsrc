# $NetBSD: buildlink3.mk,v 1.7 2006/05/07 10:38:40 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
QDBM_BUILDLINK3_MK:=	${QDBM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	qdbm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nqdbm}
BUILDLINK_PACKAGES+=	qdbm

.if !empty(QDBM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.qdbm+=	qdbm>=1.8.40
BUILDLINK_PKGSRCDIR.qdbm?=	../../databases/qdbm

.include "../../mk/pthread.buildlink3.mk"

.  if defined(PTHREAD_TYPE) && ${PTHREAD_TYPE} != "none"
CONFIGURE_ARGS+=	--enable-pthread
BUILDLINK_CFLAGS.qdbm+=	${PTHREAD_CFLAGS}
BUILDLINK_LDFLAGS.qdbm+=${PTHREAD_LDFLAGS}
.  endif
.endif	# QDBM_BUILDLINK3_MK

.include "../../archivers/bzip2/buildlink3.mk"
.include "../../archivers/lzo/buildlink3.mk"
.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/zlib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
