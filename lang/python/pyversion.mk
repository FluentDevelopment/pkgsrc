# $NetBSD: pyversion.mk,v 1.10 2002/09/20 22:32:35 jlam Exp $

.if !defined(PYTHON_PYVERSION_MK)
PYTHON_PYVERSION_MK=	defined

.include "../../mk/bsd.prefs.mk"

PYTHON_VERSION_DEFAULT?=	21
PYTHON_VERSIONS_ACCEPTED?=	22 21 20

BUILDLINK_DEPENDS.python15?=	python15>=1.5
BUILDLINK_DEPENDS.python20?=	python20>=2.0
BUILDLINK_DEPENDS.python21?=	python21>=2.1
BUILDLINK_DEPENDS.python21pth?=	python21-pth>=2.1
BUILDLINK_DEPENDS.python22?=	python22>=2.2

# transform the list into individual variables
.for pv in ${PYTHON_VERSIONS_ACCEPTED}
_PYTHON_VERSION_${pv}_OK=	yes
.endfor

# check what is installed
.if exists(${LOCALBASE}/bin/python2.2)
_PYTHON_VERSION_22_INSTALLED=	yes
.endif
.if exists(${LOCALBASE}/bin/python2.1)
_PYTHON_VERSION_21_INSTALLED=	yes
.endif
.if exists(${LOCALBASE}/bin/python2p1)
_PYTHON_VERSION_21pth_INSTALLED=yes
.endif
.if exists(${LOCALBASE}/bin/python2.0)
_PYTHON_VERSION_20_INSTALLED=	yes
.endif
.if exists(${LOCALBASE}/bin/python1.5)
_PYTHON_VERSION_15_INSTALLED=	yes
.endif

#
# choose a python version where to add,
# try to be intelligent
#
# if a version is explicitely required, take it
.if defined(PYTHON_VERSION_REQD)
_PYTHON_VERSION=	${PYTHON_VERSION_REQD}
.endif
# if the default is already installed, it is first choice
.if !defined(_PYTHON_VERSION)
.if defined(_PYTHON_VERSION_${PYTHON_VERSION_DEFAULT}_OK)
.if defined(_PYTHON_VERSION_${PYTHON_VERSION_DEFAULT}_INSTALLED)
_PYTHON_VERSION=	${PYTHON_VERSION_DEFAULT}
.endif
.endif
.endif
# prefer an already installed version, in order of "accepted"
.if !defined(_PYTHON_VERSION)
.for pv in ${PYTHON_VERSIONS_ACCEPTED}
.if defined(_PYTHON_VERSION_${pv}_INSTALLED)
_PYTHON_VERSION?=	${pv}
.else
# keep information as last resort - see below
_PYTHON_VERSION_FIRSTACCEPTED?=	${pv}
.endif
.endfor
.endif
# if the default is OK for the addon pkg, take this
.if !defined(_PYTHON_VERSION)
.if defined(_PYTHON_VERSION_${PYTHON_VERSION_DEFAULT}_OK)
_PYTHON_VERSION=	${PYTHON_VERSION_DEFAULT}
.endif
.endif
# take the first one accepted by the package
.if !defined(_PYTHON_VERSION)
_PYTHON_VERSION=	${_PYTHON_VERSION_FIRSTACCEPTED}
.endif

#
# set variables for the version we decided to use:
#  PYVERSSUFFIX: suffix to executables and in library path,
#                equal to sys.version[0:3]
#  PYPKGPREFIX: prefix to use in PKGNAME for extensions which can install
#               to multiple Python versions
#
.if ${_PYTHON_VERSION} == "22"
PYPKGSRCDIR=	../../lang/python22
PYDEPENDENCY=	${BUILDLINK_DEPENDS.python22}:${PYPKGSRCDIR}
PYVERSSUFFIX=	2.2
PYPKGPREFIX=	py22
.elif ${_PYTHON_VERSION} == "21"
PYPKGSRCDIR=	../../lang/python21
PYDEPENDENCY=	${BUILDLINK_DEPENDS.python21}:${PYPKGSRCDIR}
PYVERSSUFFIX=	2.1
PYPKGPREFIX=	py21
.elif ${_PYTHON_VERSION} == "21pth"
PYPKGSRCDIR=	../../lang/python21pth
PYDEPENDENCY=	${BUILDLINK_DEPENDS.python21pth}:${PYPKGSRCDIR}
PYVERSSUFFIX=	2p1
PYPKGPREFIX=	py21pth
.  if defined(USE_BUILDLINK2)
.    include "../../devel/pth/buildlink2.mk"
.  else
.    include "../../devel/pth/buildlink.mk"
.  endif
.elif ${_PYTHON_VERSION} == "20"
PYPKGSRCDIR=	../../lang/python20
PYDEPENDENCY=	${BUILDLINK_DEPENDS.python20}:${PYPKGSRCDIR}
PYVERSSUFFIX=	2.0
PYPKGPREFIX=	py20
.elif ${_PYTHON_VERSION} == "15"
PYPKGSRCDIR=	../../lang/python15
PYDEPENDENCY=	${BUILDLINK_DEPENDS.python15}:${PYPKGSRCDIR}
PYVERSSUFFIX=	1.5
PYPKGPREFIX=	py15
.if !defined(PYTHON_DISTUTILS_BOOTSTRAP)
BUILD_DEPENDS+=	py15-distutils-*:../../devel/py-distutils
.endif
.else
# force an error
	error: no valid Python version
.endif

PYTHONBIN=	${LOCALBASE}/bin/python${PYVERSSUFFIX}

.if defined(USE_BUILDLINK2)
.  if defined(PYTHON_FOR_BUILD_ONLY)
BUILD_DEPMETHOD.python?=	build
.  endif
.  include "${PYPKGSRCDIR}/buildlink2.mk"
.else
.  if defined(PYTHON_FOR_BUILD_ONLY)
BUILD_DEPENDS+=	${PYDEPENDENCY}
.  else
DEPENDS+=	${PYDEPENDENCY}
.  endif
.endif

.endif	# PYTHON_PYVERSION_MK
