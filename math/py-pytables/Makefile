# $NetBSD: Makefile,v 1.35 2016/08/28 15:48:33 wiz Exp $

DISTNAME=		tables-3.2.3
PKGNAME=		${PYPKGPREFIX}-py${DISTNAME}
PKGREVISION=		1
CATEGORIES=		math python
MASTER_SITES=		${MASTER_SITE_GITHUB:=PyTables/}
GITHUB_PROJECT=		PyTables
GITHUB_TAG=		v.${PKGVERSION_NOREV}

MAINTAINER=		pkgsrc-users@NetBSD.org
HOMEPAGE=		http://www.pytables.org/
COMMENT=		Database package for large amounts of data
LICENSE=		modified-bsd

WRKSRC=			${WRKDIR}/${GITHUB_PROJECT}-${GITHUB_TAG}

PYSETUPBUILDARGS+=	--hdf5=${BUILDLINK_PREFIX.hdf5}
PYSETUPINSTALLARGS=	${PYSETUPBUILDARGS}

DEPENDS+=		${PYPKGPREFIX}-numexpr>=2.0:../../math/py-numexpr

USE_LANGUAGES=		c c++

.include "options.mk"

post-install:
	cd ${DESTDIR}${PREFIX}/bin && \
		mv pt2to3 pt2to3${PYVERSSUFFIX} && \
		mv ptdump ptdump${PYVERSSUFFIX} && \
		mv ptrepack ptrepack${PYVERSSUFFIX} && \
		mv pttree pttree${PYVERSSUFFIX}

do-test:
	(cd ${WRKSRC}/tables/tests && ${PYTHONBIN} test_all.py)

.include "../../lang/python/distutils.mk"
.include "../../devel/hdf5/buildlink3.mk"
.include "../../devel/zlib/buildlink3.mk"
.include "../../archivers/bzip2/buildlink3.mk"
.include "../../math/py-numpy/buildlink3.mk"
BUILDLINK_API_DEPENDS.pycython+=	${PYPKGPREFIX}-cython>=0.21
.include "../../devel/py-cython/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
