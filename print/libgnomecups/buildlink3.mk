# $NetBSD: buildlink3.mk,v 1.5 2006/02/05 23:10:38 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBGNOMECUPS_BUILDLINK3_MK:=	${LIBGNOMECUPS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libgnomecups
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibgnomecups}
BUILDLINK_PACKAGES+=	libgnomecups

.if !empty(LIBGNOMECUPS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libgnomecups+=	libgnomecups>=0.2.0
BUILDLINK_RECOMMENDED.libgnomecups?=	libgnomecups>=0.2.2nb2
BUILDLINK_PKGSRCDIR.libgnomecups?=	../../print/libgnomecups
.endif	# LIBGNOMECUPS_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../print/cups/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
