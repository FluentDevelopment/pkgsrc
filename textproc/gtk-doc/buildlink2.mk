# $NetBSD: buildlink2.mk,v 1.2 2004/02/11 13:41:46 jmmv Exp $
#

.if !defined(GTK_DOC_BUILDLINK2_MK)
GTK_DOC_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gtk-doc
BUILDLINK_DEPENDS.gtk-doc?=	gtk-doc>=1.0
BUILDLINK_PKGSRCDIR.gtk-doc?=	../../textproc/gtk-doc
BUILDLINK_DEPMETHOD.gtk-doc?=	build

EVAL_PREFIX+=	BUILDLINK_PREFIX.gtk-doc=gtk-doc
BUILDLINK_PREFIX.gtk-doc_DEFAULT=	${LOCALBASE}

BUILDLINK_TARGETS+=	gtk-doc-buildlink

gtk-doc-buildlink: _BUILDLINK_USE

.endif	# GTK_DOC_BUILDLINK2_MK
