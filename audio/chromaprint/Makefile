# $NetBSD: Makefile,v 1.21 2017/02/24 21:54:51 maya Exp $

DISTNAME=	chromaprint-1.4.2
PKGREVISION=	2
CATEGORIES=	audio
MASTER_SITES=	https://bitbucket.org/acoustid/chromaprint/downloads/

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://acoustid.org/chromaprint
COMMENT=	Audio fingerprinting
LICENSE=	mit

USE_LANGUAGES=	c c++
USE_CMAKE=	yes
# build and install "fpcalc"
CMAKE_ARGS+=	-DBUILD_TOOLS:BOOL=ON
# tell it where to find ffmpeg
CMAKE_ARGS+=	-DFFMPEG_ROOT:PATH=${BUILDLINK_PREFIX.ffmpeg3}

PKGCONFIG_OVERRIDE=	libchromaprint.pc.cmake

# On Darwin, chromaprint uses Accelerate.framework, but fpcalc still needs FFmpeg
.include "../../multimedia/ffmpeg3/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
