# $NetBSD: buildlink2.mk,v 1.4 2002/11/04 14:51:16 wiz Exp $

.if !defined(SDL_BUILDLINK2_MK)
SDL_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		SDL
BUILDLINK_DEPENDS.SDL?=		SDL>=1.2.0
BUILDLINK_PKGSRCDIR.SDL?=	../../devel/SDL

EVAL_PREFIX+=		BUILDLINK_PREFIX.SDL=SDL
BUILDLINK_PREFIX.SDL_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.SDL=	include/SDL/*
BUILDLINK_FILES.SDL+=	lib/libSDL.*
BUILDLINK_FILES.SDL+=	lib/libSDLmain.*

USE_X11=		YES

.include "../../mk/bsd.prefs.mk"

PTHREAD_OPTS+=		require

.if defined(SDL_USE_NAS)
.  include "../../audio/nas/buildlink2.mk"
.endif
.include "../../audio/esound/buildlink2.mk"
.include "../../graphics/Mesa/buildlink2.mk"
.include "../../graphics/aalib-x11/buildlink2.mk"
.include "../../mk/pthread.buildlink2.mk"

BUILDLINK_TARGETS+=		SDL-buildlink

SDL-buildlink: _BUILDLINK_USE

.endif	# SDL_BUILDLINK2_MK
