# $NetBSD: automake.mk,v 1.1 2005/04/15 00:00:21 jlam Exp $
#
# This Makefile fragment handles packages that use GNU automake.
#
# By default, all of the automake-related scripts are marked as
# "missing" by running the GNU missing script in place of the utility.
# This hides the automake-related scripts from makefiles that aggressively
# call them when some of the inputs are modified in ways the makefiles
# don't expect.
#
# If a package needs to use GNU automake, then the package Makefile
# should contain one of the following lines:
#
#	USE_TOOLS+=	automake	# use recent GNU automake (>=1.9)
#	USE_TOOLS+=	automake14	# use GNU automake ~1.4
#
# This will allow the package to invoke "aclocal" and "automake" by
# their usual, bare names.
#
# If a particular minimum version of automake is required, then the
# package Makefile can additionally set AUTOMAKE_REQD to the desired
# version, e.g.:
#
#	AUTOMAKE_REQD=	1.8	# use at least automake>=1.8
#
# If a package additionally needs to regenerate configure scripts and
# Makefiles that use gettext, then the package Makefile should contain
# the following line:
#
#	USE_TOOLS+=	gettext-m4	# need gettext.m4 to re-gen files
#
# To globally prevent any GNU automake handling, set the following
# in the package Makefile:
#
#	AUTOMAKE_OVERRIDE=    no
#

# This variable is obsoleted, but continue to allow it until packages
# have been taught to use the new syntax.
#
.if defined(BUILD_USES_GETTEXT_M4)
USE_TOOLS+=	gettext-m4
.endif

# Only allow one of "automake" and "automake14" in USE_TOOLS.
.if !empty(USE_TOOLS:Mautomake) && !empty(USE_TOOLS:Mautomake14)
PKG_FAIL_REASON+=	"\`\`automake'' and \`\`automake14'' conflict in USE_TOOLS."
.endif

# This is an exhaustive list of all of the scripts supplied by GNU
# automake.
#
_TOOLS_AUTOMAKE=		aclocal automake

_TOOLS_AUTOMAKE.aclocal=	aclocal		aclocal-1.4		\
						aclocal-1.5		\
						aclocal-1.6		\
						aclocal-1.7		\
						aclocal-1.8		\
						aclocal-1.9
_TOOLS_AUTOMAKE.automake=	automake	automake-1.4		\
						automake-1.5		\
						automake-1.6		\
						automake-1.7		\
						automake-1.8		\
						automake-1.9

_TOOLS_AUTOMAKE_LINKS=	# empty

.if !empty(USE_TOOLS:Mautomake)
AUTOMAKE_REQD?=		1.9
BUILD_DEPENDS+=		automake>=${AUTOMAKE_REQD}:../../devel/automake
USE_TOOLS+=		autoconf
AUTOCONF_REQD?=		2.58

_TOOLS_AUTOMAKE_LINKS+=		aclocal
TOOLS_CMD.aclocal=		${TOOLS_DIR}/bin/aclocal
TOOLS_REAL_CMD.aclocal=		${LOCALBASE}/bin/aclocal

_TOOLS_AUTOMAKE_LINKS+=		automake
TOOLS_CMD.automake=		${TOOLS_DIR}/bin/automake
TOOLS_REAL_CMD.automake=	${LOCALBASE}/bin/automake

# Continue to define the following variables until packages have been
# taught to just use "aclocal" and "automake" instead.
#
ACLOCAL=	${TOOLS_CMD.aclocal}
AUTOMAKE=	${TOOLS_CMD.automake}
.endif

.if !empty(USE_TOOLS:Mautomake14)
AUTOMAKE_REQD?=		1.4
BUILD_DEPENDS+=		automake14>=${AUTOMAKE_REQD}:../../devel/automake14
USE_TOOLS+=		autoconf213
AUTOCONF_REQD?=		2.13

_TOOLS_AUTOMAKE_LINKS+=		aclocal
TOOLS_CMD.aclocal=		${TOOLS_DIR}/bin/aclocal
TOOLS_REAL_CMD.aclocal=		${LOCALBASE}/bin/aclocal-1.4

_TOOLS_AUTOMAKE_LINKS+=		automake
TOOLS_CMD.automake=		${TOOLS_DIR}/bin/automake
TOOLS_REAL_CMD.automake=	${LOCALBASE}/bin/automake-1.4

# Continue to define the following variables until packages have been
# taught to just use "aclocal" and "automake" instead.
#
ACLOCAL=	${TOOLS_CMD.aclocal}
AUTOMAKE=	${TOOLS_CMD.automake}
.endif

# For every script that hasn't already been symlinked, we mark it as
# "GNU missing".
#
AUTOMAKE_OVERRIDE?=	yes
.if !empty(AUTOMAKE_OVERRIDE:M[yY][eE][sS])
TOOLS_SYMLINK+=		${_TOOLS_AUTOMAKE_LINKS}
.  for _t_ in ${_TOOLS_AUTOMAKE_LINKS}
.    for _s_ in ${_TOOLS_AUTOMAKE.${_t_}}
.      if empty(TOOLS_REAL_CMD.${_t_}:M*/${_s_})
TOOLS_GNU_MISSING+=	${_s_}
.      endif
.    endfor
.  endfor
.  for _t_ in ${_TOOLS_AUTOMAKE}
.    if empty(_TOOLS_AUTOMAKE_LINKS:M${_t_})
.      for _s_ in ${_TOOLS_AUTOMAKE.${_t_}}
TOOLS_GNU_MISSING+=	${_s_}
.      endfor
.    endif
.  endfor
.  undef _s_
.  undef _t_
.endif

.if !empty(USE_TOOLS:Mgettext-m4)
BUILD_DEPENDS+=	{gettext-0.10.35nb1,gettext-m4-[0-9]*}:../../devel/gettext-m4
.endif
