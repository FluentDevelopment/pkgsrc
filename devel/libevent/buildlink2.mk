# $NetBSD: buildlink2.mk,v 1.2 2003/06/23 13:28:53 wiz Exp $
#
# This Makefile fragment is included by packages that use libevent.
#
# This file was created automatically using createbuildlink 2.6.
#

.if !defined(LIBEVENT_BUILDLINK2_MK)
LIBEVENT_BUILDLINK2_MK=	# defined

.if exists(/usr/include/event.h)
_NEED_LIBEVENT=		NO
.else
_NEED_LIBEVENT=		YES
.endif

.if ${_NEED_LIBEVENT} == "YES"
BUILDLINK_PACKAGES+=			libevent
BUILDLINK_DEPENDS.libevent?=		libevent>=0.6
BUILDLINK_PKGSRCDIR.libevent?=		../../devel/libevent

EVAL_PREFIX+=	BUILDLINK_PREFIX.libevent=libevent
BUILDLINK_PREFIX.libevent_DEFAULT=	${LOCALBASE}
.else
BUILDLINK_PREFIX.libevent=		/usr
.endif

BUILDLINK_FILES.libevent+=	include/event.h
BUILDLINK_FILES.libevent+=	lib/libevent.*

BUILDLINK_TARGETS+=	libevent-buildlink

libevent-buildlink: _BUILDLINK_USE

.endif	# LIBEVENT_BUILDLINK2_MK
