# $NetBSD: buildlink3.mk,v 1.5 2004/03/05 19:25:09 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
SDL_BUILDLINK3_MK:=	${SDL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	SDL
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NSDL}
BUILDLINK_PACKAGES+=	SDL

.if !empty(SDL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.SDL+=		SDL>=1.2.5nb5
BUILDLINK_PKGSRCDIR.SDL?=	../../devel/SDL

USE_X11=		yes
PTHREAD_OPTS+=		require

.include "../../graphics/MesaLib/buildlink3.mk"
.include "../../graphics/aalib-x11/buildlink3.mk"
.include "../../graphics/glut/buildlink3.mk"

.include "../../mk/pthread.buildlink3.mk"

.endif	# SDL_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
