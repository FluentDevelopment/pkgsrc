# $NetBSD: buildlink3.mk,v 1.22 2006/07/08 23:11:14 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
KDEBASE_BUILDLINK3_MK:=	${KDEBASE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	kdebase
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nkdebase}
BUILDLINK_PACKAGES+=	kdebase
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}kdebase

.if !empty(KDEBASE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.kdebase+=	kdebase>=3.5.0nb2
BUILDLINK_ABI_DEPENDS.kdebase?=	kdebase>=3.5.2nb2
BUILDLINK_PKGSRCDIR.kdebase?=	../../x11/kdebase3
.endif	# KDEBASE_BUILDLINK3_MK

.if !defined(PKG_BUILD_OPTIONS.kdebase)
PKG_BUILD_OPTIONS.kdebase!=						\
	cd ${BUILDLINK_PKGSRCDIR.kdebase} &&				\
	${MAKE} show-var ${MAKEFLAGS} VARNAME=PKG_OPTIONS
MAKEFLAGS+=	PKG_BUILD_OPTIONS.kdebase=${PKG_BUILD_OPTIONS.kdebase:Q}
.endif
MAKEVARS+=	PKG_BUILD_OPTIONS.kdebase

BUILDLINK_API_DEPENDS.Xrandr+=      Xrandr>=1.0

.include "../../databases/openldap-client/buildlink3.mk"
.include "../../fonts/fontconfig/buildlink3.mk"
.include "../../graphics/freetype2/buildlink3.mk"
.include "../../graphics/openexr/buildlink3.mk"
.if !empty(PKG_BUILD_OPTIONS.kdebase:Msamba)
.  include "../../net/samba/buildlink3.mk"
.endif
.if !empty(PKG_BUILD_OPTIONS.kdebase:Msasl)
.  include "../../security/cyrus-sasl/buildlink3.mk"
.endif
.include "../../x11/Xrandr/buildlink3.mk"
.include "../../x11/kdelibs3/buildlink3.mk"
.include "../../x11/xcursor/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
