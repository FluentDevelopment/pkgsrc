# $NetBSD: buildlink3.mk,v 1.2 2004/01/04 23:34:07 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
OPENSSL_BUILDLINK3_MK:=	${OPENSSL_BUILDLINK3_MK}+

.if !empty(OPENSSL_BUILDLINK3_MK:M+)
.  include "../../mk/bsd.prefs.mk"

# This is the ${PKGNAME} of the version of the OpenSSL package installed
# by pkgsrc.
#
_OPENSSL_PKGSRC_PKGNAME=	openssl-0.9.6l

BUILDLINK_PACKAGES+=		openssl
BUILDLINK_DEPENDS.openssl?=	openssl>=0.9.6l
BUILDLINK_PKGSRCDIR.openssl?=	../../security/openssl
.endif	# OPENSSL_BUILDLINK3_MK

BUILDLINK_CHECK_BUILTIN.openssl?=	NO

_OPENSSL_OPENSSLV_H=	/usr/include/openssl/opensslv.h

.if !defined(BUILDLINK_IS_BUILTIN.openssl)
BUILDLINK_IS_BUILTIN.openssl=	NO
.  if exists(${_OPENSSL_OPENSSLV_H})
BUILDLINK_IS_BUILTIN.openssl=	YES
.  endif
.endif

.if !empty(BUILDLINK_CHECK_BUILTIN.openssl:M[yY][eE][sS])
_NEED_OPENSSL=	NO
.endif

.if !defined(_NEED_OPENSSL)
.  if !empty(BUILDLINK_IS_BUILTIN.openssl:M[nN][oO])
_NEED_OPENSSL=	YES
.  else
#
# Create an appropriate name for the built-in package distributed
# with the system.  This package name can be used to check against
# BUILDLINK_DEPENDS.<pkg> to see if we need to install the pkgsrc
# version or if the built-in one is sufficient.
#
_OPENSSL_MAJOR!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef" }			\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = index(hex, substr($$3, 3, 1)) - 1;		\
			print i;					\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_MINOR!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef" }			\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = 16 * (index(hex, substr($$3, 4, 1)) - 1);	\
			i += index(hex, substr($$3, 5, 1)) - 1;		\
			print i;					\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_TEENY!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef" }			\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = 16 * (index(hex, substr($$3, 6, 1)) - 1);	\
			i += index(hex, substr($$3, 7, 1)) - 1;		\
			print i;					\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_PATCHLEVEL!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef";				\
			split("abcdefghijklmnopqrstuvwxyz", alpha, "");	\
		}							\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = 16 * (index(hex, substr($$3, 8, 1)) - 1);	\
			i += index(hex, substr($$3, 9, 1)) - 1;		\
			if (i == 0) {					\
				print "";				\
			} else if (i > 26) {				\
				print "a";				\
			} else {					\
				print alpha[i];				\
			}						\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_VERSION=	${_OPENSSL_MAJOR}.${_OPENSSL_MINOR}.${_OPENSSL_TEENY}${_OPENSSL_PATCHLEVEL}
_OPENSSL_PKG=	openssl-${_OPENSSL_VERSION}
#
# If the built-in OpenSSL software is 0.9.6g, then check whether it
# contains the security fixes pulled up to netbsd-1-6 on 2003-11-07.
# If it does, then treat it as the equivalent of openssl-0.9.6l.  This
# is not strictly true, but is good enough since the main differences
# between 0.9.6g and 0.9.6l are security fixes that NetBSD has already
# patched into its built-in OpenSSL software.
#    
_OPENSSL_HAS_FIX!=							\
	${AWK} 'BEGIN { ans = "NO" }					\
		/OPENSSL_HAS_20031107_FIX/ { ans = "YES" }		\
		END { print ans; exit 0 }				\
	' ${_OPENSSL_OPENSSLV_H}
.    if !empty(_OPENSSL_VERSION:M0\.9\.6g) && (${_OPENSSL_HAS_FIX} == "YES")
_OPENSSL_PKG=		openssl-0.9.6l
.    endif

_OPENSSL_DEPENDS=	${BUILDLINK_DEPENDS.openssl}
_NEED_OPENSSL!=		\
	if ${PKG_ADMIN} pmatch '${_OPENSSL_DEPENDS}' ${_OPENSSL_PKG}; then \
		${ECHO} "NO";						\
	else								\
		${ECHO} "YES";						\
	fi
.  endif
MAKEFLAGS+=	_NEED_OPENSSL="${_NEED_OPENSSL}"
.endif

.if !defined(_NEED_NEWER_OPENSSL)
_NEED_NEWER_OPENSSL!=	\
	if ${PKG_ADMIN} pmatch '${BUILDLINK_DEPENDS.openssl}' ${_OPENSSL_PKGSRC_PKGNAME}; then \
		${ECHO} "NO";						\
	else								\
		${ECHO} "YES";						\
	fi
MAKEFLAGS+=	_NEED_NEWER_OPENSSL="${_NEED_NEWER_OPENSSL}"
.endif

.if (${_NEED_OPENSSL} == "YES") && (${_NEED_NEWER_OPENSSL} == "YES")
PKG_SKIP_REASON=	"Unable to satisfy dependency: ${BUILDLINK_DEPENDS.openssl}"
.endif

.if ${_NEED_OPENSSL} == "YES"
.  if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	openssl
.  endif
.endif

.if !empty(OPENSSL_BUILDLINK3_MK:M+)
.  if ${_NEED_OPENSSL} == "NO"
BUILDLINK_PREFIX.openssl=	/usr
.  endif
SSLBASE=	${BUILDLINK_PREFIX.openssl}
BUILD_DEFS+=	SSLBASE

.  if defined(PKG_SYSCONFDIR.openssl)
SSLCERTS=	${PKG_SYSCONFDIR.openssl}/certs
.  elif ${OPSYS} == "NetBSD"
SSLCERTS=	/etc/openssl/certs
.  else
SSLCERTS=	${PKG_SYSCONFBASE}/openssl/certs
.  endif
BUILD_DEFS+=	SSLCERTS

.  if ${_NEED_OPENSSL} == "YES"
.    if defined(USE_RSAREF2) && !empty(USE_RSAREF2:M[yY][eE][sS])
BUILDLINK_DEPENDS+=	rsaref
.      include "../../security/rsaref/buildlink3.mk"
.    endif
.  endif
.endif	# OPENSSL_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
