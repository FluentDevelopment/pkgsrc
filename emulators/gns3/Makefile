# $NetBSD: Makefile,v 1.11 2017/01/01 14:43:38 wiz Exp $

DISTNAME=	GNS3-0.8.3.1-src
PKGNAME=	gns3-0.8.3.1
PKGREVISION=	2
CATEGORIES=	emulators
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE:=gns-3/GNS3/0.8.3.1/}
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://gns3.org/
COMMENT=	Graphical network simulator
LICENSE=	gnu-gpl-v2

DEPENDS+=	dynamips>=0.2.8rc1:../../emulators/dynamips

PYTHON_VERSIONS_INCOMPATIBLE=   34 35 36 # not yet ported as of 0.8.3.1
EGG_NAME=	${DISTNAME:S/-src//}
REPLACE_PYTHON+= src/GNS3/Dynagen/dynagen.py src/GNS3/Dynagen/confConsole.py
REPLACE_PYTHON+= src/GNS3/Dynagen/console.py src/GNS3/Dynagen/dynamips_lib.py
REPLACE_PYTHON+= src/GNS3/Dynagen/qemu_lib.py
REPLACE_PYTHON+= src/GNS3/Dynagen/dynagen_vbox_lib.py
REPLACE_PYTHON+= src/GNS3/Dynagen/portTracker_lib.py

.include "../../lang/python/application.mk"
.include "../../lang/python/distutils.mk"
.include "../../x11/py-sip/buildlink3.mk"
.include "../../x11/py-qt4/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
