# $NetBSD: buildlink2.mk,v 1.4 2002/12/24 06:10:31 wiz Exp $

.include "../../lang/python/pyversion.mk"

BUILDLINK_PACKAGES+=		pygnome
BUILDLINK_DEPENDS.pygnome?=	${PYPKGPREFIX}-gnome>=1.4.0nb3
BUILDLINK_PKGSRCDIR.pygnome?=	../../x11/gnome-python
