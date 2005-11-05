# $NetBSD: Makefile.php,v 1.13 2005/11/05 17:18:28 rillig Exp $
#

.include "../../lang/php5/Makefile.common"

DISTINFO_FILE=	${.CURDIR}/../../lang/php5/distinfo

BUILD_DEFS=		USE_INET6

USE_LIBTOOL=		YES
GNU_CONFIGURE=		YES

CONFIGURE_ENV+=		EXTENSION_DIR="${PREFIX}/${PHP_EXTENSION_DIR}"

PHP_EXTENSION_DIR=	lib/php/20040412
PLIST_SUBST+=		PHP_EXTENSION_DIR=${PHP_EXTENSION_DIR}

.include "../../mk/bsd.prefs.mk"

CONFIGURE_ARGS+=	--with-config-file-path=${PKG_SYSCONFDIR}

# The Solaris system regex structures miss re_magic used by PHP build 
.if (${OPSYS} != "SunOS") && (${OPSYS} != "Linux")
CONFIGURE_ARGS+=	--with-regex=system
.else
CONFIGURE_ARGS+=	--with-regex=php
.endif

CONFIGURE_ARGS+=	--without-mysql
CONFIGURE_ARGS+=	--without-sqlite
CONFIGURE_ARGS+=	--without-iconv

CONFIGURE_ARGS+=	--enable-memory-limit
CONFIGURE_ARGS+=	--enable-track-vars

CONFIGURE_ARGS+=	--disable-posix
CONFIGURE_ARGS+=	--disable-dom

CONFIGURE_ARGS+=	--enable-xml
CONFIGURE_ARGS+=	--with-libxml-dir=${PREFIX}
.include "../../textproc/libxml2/buildlink3.mk"

PKG_OPTIONS_VAR=	PKG_OPTIONS.${PKGBASE}
PKG_SUPPORTED_OPTIONS+=	inet6 ssl
PKG_SUGGESTED_OPTIONS+=	ssl

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Minet6)
CONFIGURE_ARGS+=	--enable-ipv6
.else
CONFIGURE_ARGS+=	--disable-ipv6
.endif

.if !empty(PKG_OPTIONS:Mssl)
.  include "../../security/openssl/buildlink3.mk"
CONFIGURE_ARGS+=	--with-openssl
.else
CONFIGURE_ARGS+=	--without-openssl
.endif
