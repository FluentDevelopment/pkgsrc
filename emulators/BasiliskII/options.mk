# $NetBSD: options.mk,v 1.1 2005/07/01 12:34:32 adam Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.BasiliskII
PKG_SUPPORTED_OPTIONS=	esd gtk sdl

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mesd)
CONFIGURE_ARGS+=	--with-esd
.include "../../audio/esound/buildlink3.mk"
.else
CONFIGURE_ARGS+=	--without-esd
.endif

.if !empty(PKG_OPTIONS:Mgtk)
CONFIGURE_ARGS+=	--with-gtk
.include "../../x11/gtk/buildlink3.mk"
.else
CONFIGURE_ARGS+=	--without-gtk
.endif

.if !empty(PKG_OPTIONS:Msdl)
CONFIGURE_ARGS+=	--enable-sdl-audio
CONFIGURE_ARGS+=	--enable-sdl-video
.include "../../devel/SDL/buildlink3.mk"
.else
.include "../../mk/x11.buildlink3.mk"
.endif
