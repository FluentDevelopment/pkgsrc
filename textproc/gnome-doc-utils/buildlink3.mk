# $NetBSD: buildlink3.mk,v 1.9 2006/04/12 10:27:37 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
GNOME_DOC_UTILS_BUILDLINK3_MK:=	${GNOME_DOC_UTILS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gnome-doc-utils
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngnome-doc-utils}
BUILDLINK_PACKAGES+=	gnome-doc-utils

.if !empty(GNOME_DOC_UTILS_BUILDLINK3_MK:M+)
BUILDLINK_DEPMETHOD.gnome-doc-utils+=	build
BUILDLINK_API_DEPENDS.gnome-doc-utils+=	gnome-doc-utils>=0.6.0
BUILDLINK_PKGSRCDIR.gnome-doc-utils?=	../../textproc/gnome-doc-utils
.endif	# GNOME_DOC_UTILS_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
