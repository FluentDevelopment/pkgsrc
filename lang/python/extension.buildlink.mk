# $NetBSD: extension.buildlink.mk,v 1.11 2002/09/04 14:28:37 drochner Exp $

# derive a python version from the package name if possible
.if defined(PKGNAME_REQD)
PYTHON_VERSION_REQD?= ${PKGNAME_REQD:C/^py([^-]*)-.*/\1/}
.endif

.include "../../lang/python/pyversion.mk"

#
# below is what used to be in bsd.python.mk
#

.if defined(PYBINMODULE)
.if ${MACHINE_ARCH} == "mips" || ${MACHINE_ARCH} == "vax"
IGNORE="${PKGNAME} needs dynamic loading"
.endif
.endif

.if exists(${PYTHONBIN})
PYINC!=	${PYTHONBIN} -c "import distutils.sysconfig; \
	print distutils.sysconfig.get_python_inc(0, \"\")" || ${ECHO} ""
PYLIB!=	${PYTHONBIN} -c "import distutils.sysconfig; \
	print distutils.sysconfig.get_python_lib(0, 1, \"\")" || ${ECHO} ""
PYSITELIB!= ${PYTHONBIN} -c "import distutils.sysconfig; \
	print distutils.sysconfig.get_python_lib(0, 0, \"\")" || ${ECHO} ""
.endif

.if defined(PYDISTUTILSPKG)
PYSETUP?=		setup.py
PYSETUPBUILDARGS?=	#empty
PYSETUPINSTALLARGS?=	#empty
PY_PATCHPLIST?=		yes

do-build:
	(cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${PYTHONBIN} \
	 ${PYSETUP} ${PYSETUPBUILDARGS} build)

do-install:
	(cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${PYTHONBIN} \
	 ${PYSETUP} ${PYSETUPINSTALLARGS} install)
.endif

.if defined(PY_PATCHPLIST)
PLIST_SUBST+=	PYINC=${PYINC} PYSITELIB=${PYSITELIB}
.endif
