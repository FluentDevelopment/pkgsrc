# $NetBSD: Makefile,v 1.7 2017/04/20 13:45:52 jperkin Exp $

DISTNAME=	zstd-1.1.4
CATEGORIES=	archivers
MASTER_SITES=	${MASTER_SITE_GITHUB:=facebook/}
GITHUB_TAG=	v${PKGVERSION_NOREV}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://www.zstd.net/
COMMENT=	Fast real-time compression algorithm
LICENSE=	modified-bsd

USE_TOOLS+=	gmake pkg-config
USE_LANGUAGES+=	c c++
MAKE_FLAGS=	MANDIR=${PREFIX}/${PKGMANDIR}/man1
MAKE_FLAGS+=	INSTALL=${INSTALL:Q}
MAKE_JOBS_SAFE=	no

PKGCONFIG_OVERRIDE+=	lib/libzstd.pc.in

.include "../../devel/zlib/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
