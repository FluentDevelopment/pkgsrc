# $NetBSD: gcc3.mk,v 1.1 2003/07/06 12:15:08 drochner Exp $
#
# make configuration file for @PKGNAME_NOREV@

USE_GCC3=	# defined
CC=		@GCC_PREFIX@/bin/cc
CPP=		@GCC_PREFIX@/bin/cpp
CXX=		@GCC_PREFIX@/bin/c++
F77=		@GCC_PREFIX@/bin/g77
PKG_FC=		@GCC_PREFIX@/bin/g77
