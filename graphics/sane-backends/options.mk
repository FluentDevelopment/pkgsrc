# $NetBSD: options.mk,v 1.3 2007/01/30 07:09:03 wiz Exp $

PKG_OPTIONS_VAR=                PKG_OPTIONS.sane-backends
PKG_SUPPORTED_OPTIONS=          sane-backends-hp3900
PKG_SUGGESTED_OPTIONS=		#defined

.include "../../mk/bsd.options.mk"

# Package-specific option-handling

###
### hp3900 support
###
.if !empty(PKG_OPTIONS:Mhp3900)
PLIST_SUBST+=   SANE_HP3900=""
DISTFILES+=	hp3900-sane1017_src_0.5.tar.gz
SITES.hp3900-sane1017_src_0.5.tar.gz=${MASTER_SITE_SOURCEFORGE:=hp3900-series/}
post-patch:
	cd ${WRKSRC} && \
	${PATCH} -p1 <${WRKDIR}/hp3900-sane1017_src_0.5/hp3900-sane1017_0.5.diff
.else
PLIST_SUBST+=   SANE_HP3900="@comment "
.endif
