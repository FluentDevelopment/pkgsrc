# $NetBSD: Makefile,v 1.11 2017/04/22 21:03:09 adam Exp $

DISTNAME=	kcmutils-${KF5VER}
PKGREVISION=	7
CATEGORIES=	devel

HOMEPAGE=	https://community.kde.org/Frameworks
COMMENT=	Utilities for interacting with KCModules
LICENSE=	gnu-lgpl-v2.1

USE_TOOLS+=	msgmerge

.include "../../meta-pkgs/kf5/Makefile.common"

.include "../../devel/kdeclarative/buildlink3.mk"
.include "../../x11/qt5-qtbase/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
