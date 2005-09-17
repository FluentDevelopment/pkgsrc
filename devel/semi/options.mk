# $NetBSD: options.mk,v 1.2 2005/09/17 16:41:24 uebayasi Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.semi
PKG_SUPPORTED_OPTIONS=	semi-bbdb
PKG_OPTIONS_OPTIONAL_GROUPS=	semi-browser
PKG_OPTIONS_GROUP.semi-browser=	w3 w3m
PKG_SUGGESTED_OPTIONS=

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mbbdb)
DEPENDS+=	bbdb-[0-9]*:../../misc/bbdb
PLIST_SUBST+=	FOR_bbdb=
.else
PLIST_SUBST+=	FOR_bbdb="@comment "
.endif

.if !empty(PKG_OPTIONS:Mw3)
DEPENDS+=	w3-[0-9]*:../../www/w3
PLIST_SUBST+=	FOR_w3=
.else
PLIST_SUBST+=	FOR_w3="@comment "
.endif

.if !empty(PKG_OPTIONS:Mw3m)
DEPENDS+=	w3m-[0-9]*:../../www/emacs-w3m
.endif
