# $NetBSD: buildlink3.mk,v 1.1 2004/03/11 00:50:14 jlam Exp $
#
# Don't include this file manually!  It will be included as necessary
# by bsd.buildlink3.mk.

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
X11_LINKS_BUILDLINK3_MK:=	${X11_LINKS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	x11-links
.endif

# x11-links must come first so that packages listed later can overwrite
# any symlinks created by buildlinking x11-links.
#
BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nx11-links}
BUILDLINK_PACKAGES:=	x11-links ${BUILDLINK_PACKAGES}

.if !empty(X11_LINKS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.x11-links+=	x11-links>=0.23
BUILDLINK_PKGSRCDIR.x11-links?=	../../pkgtools/x11-links
BUILDLINK_DEPMETHOD.x11-links?=	build

# Rename the symlinks so that they appear in ${BUILDLINK_X11_DIR}/include
# and ${BUILDLINK_X11_DIR}/lib.
#
BUILDLINK_TRANSFORM.x11-links+=	-e "s|/share/x11-links/|/|"

.endif	# X11_LINKS_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
