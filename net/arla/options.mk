# $NetBSD: options.mk,v 1.2 2007/02/22 19:26:52 wiz Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.arla
PKG_SUPPORTED_OPTIONS=	x11
PKG_SUGGESTED_OPTIONS=

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mx11)
CONFIGURE_ARGS+=	--with-x
PLIST_SUBST+=		X11_SUPPORT=
.include "../../mk/x11.buildlink3.mk"
.else
CONFIGURE_ARGS+=	--without-x
PLIST_SUBST+=		X11_SUPPORT='@comment '
.endif
