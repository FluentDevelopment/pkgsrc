# $NetBSD: buildlink2.mk,v 1.3 2004/03/26 02:27:42 wiz Exp $

.if !defined(PYTHON23_BUILDLINK2_MK)
PYTHON23_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_PACKAGES+=		python23pth
BUILDLINK_PKGBASE.python23pth?=	python23-pth
BUILDLINK_DEPENDS.python23pth?=	python23-pth>=2.3
BUILDLINK_RECOMMENDED.python23pth?=	python23-pth>=2.3.3nb2
BUILDLINK_PKGSRCDIR.python23pth?=	../../lang/python23-pth

.if defined(BUILDLINK_DEPMETHOD.python)
BUILDLINK_DEPMETHOD.python23pth?=	${BUILDLINK_DEPMETHOD.python}
.endif

EVAL_PREFIX+=	BUILDLINK_PREFIX.python23pth=python23-pth
BUILDLINK_PREFIX.python23pth_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES_CMD.python23pth= \
	${BUILDLINK_PLIST_CMD.python23pth} |				\
		${EGREP} '^(include|lib.*/lib[^/]*$$)'
BUILDLINK_TRANSFORM+=		l:python:python2p3

BUILDLINK_CPPFLAGS.python23pth+= \
	-I${BUILDLINK_PREFIX.python23pth}/include/python2p3
BUILDLINK_LDFLAGS.python23pth+= \
	-L${BUILDLINK_PREFIX.python23pth}/lib/python2p3/config		\
	-Wl,-R${BUILDLINK_PREFIX.python23pth}/lib/python2p3/config

BUILDLINK_TARGETS+=	python23pth-buildlink

python23pth-buildlink: _BUILDLINK_USE

.endif	# PYTHON23_BUILDLINK2_MK
