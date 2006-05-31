# $NetBSD: options.mk,v 1.5 2006/05/31 18:22:23 ghen Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.wine
PKG_SUPPORTED_OPTIONS=	arts cups opengl sane

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Marts)
.include "../../audio/arts/buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mcups)
.include "../../print/cups/buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mopengl)
PLIST_SUBST+=	WINE_OPENGL=""
.include "../../graphics/glu/buildlink3.mk"
.include "../../graphics/glut/buildlink3.mk"
.else
CONFIGURE_ARGS+=	--without-opengl
PLIST_SUBST+=	WINE_OPENGL="@comment "
.endif

.if !empty(PKG_OPTIONS:Msane)
.include "../../graphics/sane-backends/buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mopengl)
.else
CONFIGURE_ARGS+=	--without-opengl
.endif
