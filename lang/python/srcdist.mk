# $NetBSD: srcdist.mk,v 1.4 2002/08/20 20:00:14 drochner Exp $

.include "../../lang/python/pyversion.mk"

.if ${_PYTHON_VERSION} == "22"

DISTNAME=	Python-2.2.1
EXTRACT_SUFX=	.tgz
DISTINFO_FILE=	${.CURDIR}/../../lang/python22/distinfo
PATCHDIR=	${.CURDIR}/../../lang/python22/patches
PYSUBDIR=	Python-2.2.1
WRKSRC=		${WRKDIR}/${PYSUBDIR}
MASTER_SITES=	ftp://ftp.python.org/pub/python/2.2.1/

.elif ${_PYTHON_VERSION} == "21" || ${_PYTHON_VERSION} == "21pth"

DISTNAME=	Python-2.1.3
EXTRACT_SUFX=	.tgz
DISTINFO_FILE=	${.CURDIR}/../../lang/python21/distinfo
PATCHDIR=	${.CURDIR}/../../lang/python21/patches
PYSUBDIR=	Python-2.1.3
WRKSRC=		${WRKDIR}/${PYSUBDIR}
MASTER_SITES=	ftp://ftp.python.org/pub/python/2.1.3/

.elif ${_PYTHON_VERSION} == "20"

DISTNAME=	Python-2.0.1
# for historical reasons
DIST_SUBDIR=	python
EXTRACT_SUFX=	.tgz
DISTINFO_FILE=	${.CURDIR}/../../lang/python20/distinfo
PATCHDIR=	${.CURDIR}/../../lang/python20/patches
PYSUBDIR=	Python-2.0.1
WRKSRC=		${WRKDIR}/${PYSUBDIR}
MASTER_SITES=	ftp://ftp.python.org/pub/python/2.0.1/

.elif ${_PYTHON_VERSION} == "15"

DISTNAME=	py152
EXTRACT_SUFX=	.tgz
DISTINFO_FILE=	${.CURDIR}/../../lang/python15/distinfo
PATCHDIR=	${.CURDIR}/../../lang/python15/patches
PYSUBDIR=	Python-1.5.2
WRKSRC=		${WRKDIR}/${PYSUBDIR}
MASTER_SITES=	http://www.python.org/ftp/python/src/

.endif

.if defined(PYDISTUTILSPKG)
# This is used for standard modules shipped with Python but build as
# separate packages.

python-std-patchsetup:
	${SED} ${PY_SETUP_SUBST:S/=/@!/:S/$/!g/:S/^/ -e s!@/} \
		<${FILESDIR}/setup.py >${WRKSRC}/setup.py

post-extract: python-std-patchsetup
.endif
