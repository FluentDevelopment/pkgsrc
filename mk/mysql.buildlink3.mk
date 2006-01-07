# $NetBSD: mysql.buildlink3.mk,v 1.5 2006/01/07 10:47:39 xtraeme Exp $

.if !defined(MYSQL_VERSION_MK)
MYSQL_VERSION_MK=	# defined

.include "../../mk/bsd.prefs.mk"

MYSQL_VERSION_DEFAULT?=		50
MYSQL_VERSIONS_ACCEPTED?=	50 41

# transform the list into individual variables
.for mv in ${MYSQL_VERSIONS_ACCEPTED}
_MYSQL_VERSION_${mv}_OK=	yes
.endfor

# check what is installed
.if exists(${LOCALBASE}/lib/mysql/libmysqlclient.so.15)
_MYSQL_VERSION_50_INSTALLED=	yes
.endif

.if exists(${LOCALBASE}/lib/mysql/libmysqlclient.so.14)
_MYSQL_VERSION_41_INSTALLED=	yes
.endif

.if exists(${LOCALBASE}/lib/mysql/libmysqlclient.so.12)
_MYSQL_VERSION_40_INSTALLED=	yes
.endif

# if a version is explicitely required, take it
.if defined(MYSQL_VERSION_REQD)
_MYSQL_VERSION=	${MYSQL_VERSION_REQD}
.endif
# if the default is already installed, it is first choice
.if !defined(_MYSQL_VERSION)
.  if defined(_MYSQL_VERSION_${MYSQL_VERSION_DEFAULT}_OK)
.    if defined(_MYSQL_VERSION_${MYSQL_VERSION_DEFAULT}_INSTALLED)
_MYSQL_VERSION=	${MYSQL_VERSION_DEFAULT}
.    endif
.  endif
.endif
# prefer an already installed version, in order of "accepted"
.if !defined(_MYSQL_VERSION)
.  for mv in ${MYSQL_VERSIONS_ACCEPTED}
.    if defined(_MYSQL_VERSION_${mv}_INSTALLED)
_MYSQL_VERSION?=	${mv}
.    else
# keep information as last resort - see below
_MYSQL_VERSION_FIRSTACCEPTED?=	${mv}
.    endif
.  endfor
.endif
# if the default is OK for the addon pkg, take this
.if !defined(_MYSQL_VERSION)
.  if defined(_MYSQL_VERSION_${MYSQL_VERSION_DEFAULT}_OK)
_MYSQL_VERSION=	${MYSQL_VERSION_DEFAULT}
.  endif
.endif
# take the first one accepted by the package
.if !defined(_MYSQL_VERSION)
_MYSQL_VERSION=	${_MYSQL_VERSION_FIRSTACCEPTED}
.endif

#
# set variables for the version we decided to use:
#
.if ${_MYSQL_VERSION} == "50"
MYSQL_PKGSRCDIR=	../../databases/mysql5-client
.elif ${_MYSQL_VERSION} == "41"
MYSQL_PKGSRCDIR=	../../databases/mysql4-client
.else
# force an error
PKG_SKIP_REASON+=	"${_MYSQL_VERSION} is not a valid mysql package."
.endif

.include "${MYSQL_PKGSRCDIR}/buildlink3.mk"

.endif	# MYSQL_VERSION_MK
