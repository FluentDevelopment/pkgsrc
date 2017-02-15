# $NetBSD: options.mk,v 1.10 2016/10/03 11:55:11 wiz Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.openssl
PKG_SUPPORTED_OPTIONS=	chacha20 idea md2 mdc2 rc5 zlib threads
PKG_SUGGESTED_OPTIONS=	idea md2 mdc2 threads

.include "../../mk/bsd.options.mk"

PLIST_VARS+=		${PKG_SUPPORTED_OPTIONS}

#
# Support optional algorithms
#
.for alg in idea md2 mdc2 rc5
.  if !empty(PKG_OPTIONS:M${alg})
CONFIGURE_ARGS+=	enable-${alg}
PLIST.${alg}=		yes
.  else
CONFIGURE_ARGS+=	no-${alg}
.  endif
.endfor

# A license file is needed.
# US Patent: 5724428, 5835600, 6269163
.if !empty(PKG_OPTIONS:Mrc5)
LICENSE+=	AND rc5-nonlicense
.endif

.if !empty(PKG_OPTIONS:Mzlib)
CONFIGURE_ARGS+=	zlib
.include "../../devel/zlib/buildlink3.mk"
.else
CONFIGURE_ARGS+=	no-zlib
.endif

.if !empty(PKG_OPTIONS:Mthreads)
CONFIGURE_ARGS+=	threads
.else
CONFIGURE_ARGS+=	no-threads
.endif

.if !empty(PKG_OPTIONS:Mchacha20) || make(makesum)
CHACHA20_PATCH=		openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch
PATCHFILES+=		${CHACHA20_PATCH}
SITES.${CHACHA20_PATCH}= https://raw.githubusercontent.com/cloudflare/sslconfig/master/patches/
PATCH_DIST_STRIP.${CHACHA20_PATCH}= -p1
PLIST.chacha20=		yes
.endif
