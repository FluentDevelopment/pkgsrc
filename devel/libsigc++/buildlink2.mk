# $NetBSD: buildlink2.mk,v 1.10 2004/04/15 00:49:29 wiz Exp $
#
# This Makefile fragment is included by packages that use libsigc++.
#
# This file was created automatically using createbuildlink 2.4.
#

.if !defined(LIBSIGCXX_BUILDLINK2_MK)
LIBSIGCXX_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libsigcxx
BUILDLINK_PKGBASE.libsigcxx?=		libsigc++
BUILDLINK_DEPENDS.libsigcxx?=		libsigc++>=1.2.3nb1
BUILDLINK_PKGSRCDIR.libsigcxx?=		../../devel/libsigc++

EVAL_PREFIX+=	BUILDLINK_PREFIX.libsigcxx=libsigcxx
BUILDLINK_PREFIX.libsigcxx_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libsigcxx+=	include/sigc++-1.2/sigc++/*
BUILDLINK_FILES.libsigcxx+=	include/sigc++-1.2/sigc++/macros/*
BUILDLINK_FILES.libsigcxx+=	lib/libsigc-1.2.*
BUILDLINK_FILES.libsigcxx+=	lib/sigc++-1.2/include/*

BUILDLINK_TARGETS+=	libsigcxx-buildlink

libsigcxx-buildlink: _BUILDLINK_USE

.endif	# LIBSIGCXX_BUILDLINK2_MK
