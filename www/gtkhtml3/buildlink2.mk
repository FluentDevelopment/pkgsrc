# $NetBSD: buildlink2.mk,v 1.3 2004/01/03 18:49:55 reed Exp $
#

.if !defined(GTKHTML_BUILDLINK2_MK)
GTKHTML_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			gtkhtml3
BUILDLINK_DEPENDS.gtkhtml?=		gtkhtml3>=3.0.9nb2
BUILDLINK_PKGSRCDIR.gtkhtml?=		../../www/gtkhtml3

EVAL_PREFIX+=	BUILDLINK_PREFIX.gtkhtml=gtkhtml
BUILDLINK_PREFIX.gtkhtml_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gtkhtml+=	include/libgtkhtml-3.0/gtkhtml/*.h
BUILDLINK_FILES.gtkhtml+=	lib/bonobo/servers/GNOME_GtkHTML_Editor.server
BUILDLINK_FILES.gtkhtml+=	lib/gtkhtml/libgnome-gtkhtml-editor-3.0.*
BUILDLINK_FILES.gtkhtml+=	lib/libgtkhtml-3.0.*
BUILDLINK_FILES.gtkhtml+=	lib/libgtkhtml-a11y-3.0.*

.include "../../devel/gail/buildlink2.mk"
.include "../../devel/gal2/buildlink2.mk"
.include "../../net/libsoup/buildlink2.mk"

BUILDLINK_TARGETS+=	gtkhtml-buildlink

gtkhtml-buildlink: _BUILDLINK_USE

.endif	# GTKHTML_BUILDLINK2_MK
