# $NetBSD: Makefile,v 1.11 2017/01/01 14:43:34 wiz Exp $

DISTNAME=	multiprocessing-2.6.2.1
PKGNAME=	${PYPKGPREFIX}-multiprocessing-2.6.2.1
CATEGORIES=	devel
MASTER_SITES=	${MASTER_SITE_PYPI:=m/multiprocessing/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://pypi.python.org/pypi/multiprocessing/
COMMENT=	Python threading package
LICENSE=	modified-bsd

PYTHON_VERSIONS_INCOMPATIBLE=	34 35 36 # does not make sense, python-3.x has it included

CFLAGS.SunOS+=	-D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED=1

do-test:
	${PYTHONBIN} -c "from multiprocessing import tests;tests.test_main()"

.include "../../lang/python/egg.mk"
.include "../../mk/bsd.pkg.mk"
