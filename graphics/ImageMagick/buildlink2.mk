# $NetBSD: buildlink2.mk,v 1.6 2004/01/03 18:49:41 reed Exp $

.if !defined(IMAGEMAGICK_BUILDLINK2_MK)
IMAGEMAGICK_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			ImageMagick
BUILDLINK_DEPENDS.ImageMagick?=		ImageMagick>=5.5.7.11nb1
BUILDLINK_PKGSRCDIR.ImageMagick?=	../../graphics/ImageMagick

EVAL_PREFIX+=			BUILDLINK_PREFIX.ImageMagick=ImageMagick
BUILDLINK_PREFIX.ImageMagick_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.ImageMagick=	include/Magick++.h
BUILDLINK_FILES.ImageMagick+=	include/Magick++/*
BUILDLINK_FILES.ImageMagick+=	include/magick/*
BUILDLINK_FILES.ImageMagick+=	lib/libMagick.*
BUILDLINK_FILES.ImageMagick+=	lib/libMagick++.*

.include "../../archivers/bzip2/buildlink2.mk"
.include "../../graphics/jasper/buildlink2.mk"
.include "../../graphics/jpeg/buildlink2.mk"
.include "../../graphics/png/buildlink2.mk"
.include "../../graphics/tiff/buildlink2.mk"

BUILDLINK_TARGETS+=	ImageMagick-buildlink

ImageMagick-buildlink: _BUILDLINK_USE

.endif	# IMAGEMAGICK_BUILDLINK2_MK
