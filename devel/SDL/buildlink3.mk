# $NetBSD: buildlink3.mk,v 1.1 2004/01/03 23:06:43 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
SDL_BUILDLINK3_MK:=	${SDL_BUILDLINK3_MK}+

.if !empty(SDL_BUILDLINK3_MK:M\+)
.  include "../../mk/bsd.prefs.mk"

BUILDLINK_DEPENDS.SDL?=		SDL>=1.2.5nb5
BUILDLINK_PKGSRCDIR.SDL?=	../../devel/SDL
.endif	# SDL_BUILDLINK3_MK

.if !empty(BUILDLINK_DEPTH:M\+)
BUILDLINK_DEPENDS+=	SDL
.endif

.if !empty(SDL_BUILDLINK3_MK:M\+)
BUILDLINK_PACKAGES+=	SDL

USE_X11=		YES
PTHREAD_OPTS+=		require

.  include "../../graphics/MesaLib/buildlink3.mk"
.  include "../../graphics/glut/buildlink3.mk"
.  include "../../graphics/aalib-x11/buildlink3.mk"
.  include "../../mk/pthread.buildlink3.mk"
.endif	# SDL_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
