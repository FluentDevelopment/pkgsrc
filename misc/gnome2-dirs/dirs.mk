# $NetBSD: dirs.mk,v 1.1 2004/04/14 15:26:41 jmmv Exp $
#
# This file is intended to be included by mk/dirs.mk, not directly by packages.
#

.if !defined(DIRS_GNOME2_MK)
DIRS_GNOME2_MK=		# defined

_USE_XDG_DIRS=		1.1
.include "../../misc/xdg-dirs/dirs.mk"
.include "../../misc/gnome-dirs/dirs.mk"

GNOME2_DIRS=		share/control-center-2.0
GNOME2_DIRS+=		share/control-center-2.0/capplets
GNOME2_DIRS+=		share/control-center-2.0/icons
GNOME2_DIRS+=		share/gnome-2.0
GNOME2_DIRS+=		share/gnome-2.0/ui
GNOME2_DIRS+=		share/gnome/wm-properties

.if defined(_USE_GNOME2_DIRS) && !empty(_USE_GNOME2_DIRS)
DEPENDS+=		gnome2-dirs>=${_USE_GNOME2_DIRS}:../../misc/gnome2-dirs

.  for dir in ${GNOME_DIRS} ${GNOME2_DIRS}
PRINT_PLIST_AWK+=	/^@dirrm ${dir:S|/|\\/|g}$$/ \
				{ print "@comment in gnome2-dirs: " $$0; next; }
.  endfor
.  undef dir
.endif

.endif			# !defined(DIRS_GNOME2_MK)
