# $NetBSD: bsd.buildlink2.mk,v 1.35 2002/09/28 23:46:42 jlam Exp $
#
# An example package buildlink2.mk file:
#
# -------------8<-------------8<-------------8<-------------8<-------------
# BUILDLINK_PACKAGES+=		foo
# BUILDLINK_DEPENDS.foo?=	foo>=1.0
# BUILDLINK_PKGSRCDIR.foo?=	../../category/foo
#
# EVAL_PREFIX+=			BUILDLINK_PREFIX.foo=foo
# BUILDLINK_PREFIX.foo_DEFAULT=	${LOCALBASE}
# BUILDLINK_FILES.foo=		include/foo.h
# BUILDLINK_FILES.foo+=		include/bar.h
# BUILDLINK_FILES.foo+=		lib/libfoo.*
#
# # We want "-lbar" to eventually resolve to "-lfoo".
# BUILDLINK_TRANSFORM+=		l:bar:foo
#
# BUILDLINK_TARGETS+=		foo-buildlink
#
# foo-buildlink: _BUILDLINK_USE
# -------------8<-------------8<-------------8<-------------8<-------------
#
# The different variables that may be set in a buildlink2.mk file are
# described below.
#
# The variable name convention used in this Makefile are:
#
# BUILDLINK_*	public buildlink-related variables usable in other Makefiles
# _BLNK_*	private buildlink-related variables to this Makefile

ECHO_BUILDLINK_MSG?=	${TRUE}

BUILDLINK_DIR=		${WRKDIR}/.buildlink
BUILDLINK_X11PKG_DIR=	${BUILDLINK_DIR:H}/.buildlink-x11pkg
CONFIGURE_ENV+=		BUILDLINK_DIR="${BUILDLINK_DIR}"
MAKE_ENV+=		BUILDLINK_DIR="${BUILDLINK_DIR}"
CONFIGURE_ENV+=		BUILDLINK_X11PKG_DIR="${BUILDLINK_X11PKG_DIR}"
MAKE_ENV+=		BUILDLINK_X11PKG_DIR="${BUILDLINK_X11PKG_DIR}"
_BLNK_CPPFLAGS=		-I${LOCALBASE}/include
_BLNK_LDFLAGS=		-L${LOCALBASE}/lib
_BLNK_OPSYS=		${OPSYS}

# The configure process usually tests for outlandish or missing things
# that we don't want polluting the argument cache.
#
CONFIGURE_ENV+=		BUILDLINK_UPDATE_CACHE=no

.if defined(USE_X11) || defined(USE_X11BASE) || defined(USE_IMAKE)
USE_X11_LINKS?=		YES
.  if !empty(USE_X11_LINKS:M[nN][oO])
.    include "../../mk/x11.buildlink2.mk"
BUILDLINK_X11_DIR=	${BUILDLINK_X11PKG_DIR}
.  else
BUILD_DEPENDS+=		x11-links>=0.8:../../pkgtools/x11-links
BUILDLINK_X11_DIR=	${LOCALBASE}/share/x11-links
.  endif
CONFIGURE_ENV+=		BUILDLINK_X11_DIR="${BUILDLINK_X11_DIR}"
MAKE_ENV+=		BUILDLINK_X11_DIR="${BUILDLINK_X11_DIR}"
_BLNK_CPPFLAGS+=	-I${X11BASE}/include
_BLNK_LDFLAGS+=		-L${X11BASE}/lib
.endif

CFLAGS:=		${_BLNK_CPPFLAGS} ${CFLAGS}
CXXFLAGS:=		${_BLNK_CPPFLAGS} ${CXXFLAGS}
CPPFLAGS:=		${_BLNK_CPPFLAGS} ${CPPFLAGS}
LDFLAGS:=		${_BLNK_LDFLAGS} ${LDFLAGS}

# Prepend ${BUILDLINK_DIR}/bin to the PATH so that the wrappers are found
# first when searching for executables.
#
PATH:=			${BUILDLINK_DIR}/bin:${PATH}

# Add the proper dependency on each package pulled in by buildlink2.mk
# files.  BUILDLINK_DEPMETHOD.<pkg> contains a list of either "full" or
# "build", and if any of that list if "full" then we use a full dependency
# on <pkg>, otherwise we use a build dependency on <pkg>.  By default,
# we use a full dependency.
#
.for _pkg_ in ${BUILDLINK_PACKAGES}
.  if !defined(BUILDLINK_DEPMETHOD.${_pkg_})
BUILDLINK_DEPMETHOD.${_pkg_}=	full
.  endif
.  if !empty(BUILDLINK_DEPMETHOD.${_pkg_}:Mfull)
_BUILDLINK_DEPMETHOD.${_pkg_}=	DEPENDS
.  elif !empty(BUILDLINK_DEPMETHOD.${_pkg_}:Mbuild)
_BUILDLINK_DEPMETHOD.${_pkg_}=	BUILD_DEPENDS
.  endif
.  if defined(BUILDLINK_DEPENDS.${_pkg_}) && \
      defined(BUILDLINK_PKGSRCDIR.${_pkg_})
.    for _depends_ in ${BUILDLINK_DEPENDS.${_pkg_}}
${_BUILDLINK_DEPMETHOD.${_pkg_}}+= \
	${_depends_}:${BUILDLINK_PKGSRCDIR.${_pkg_}}
.    endfor
.  endif
.endfor

# Create the buildlink include and lib directories so that the Darwin
# compiler/linker won't complain verbosely (on stdout, even!) when
# those directories are passed as sub-arguments of -I and -L.
#
do-buildlink: buildlink-directories
buildlink-directories:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${BUILDLINK_DIR}/include
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${BUILDLINK_DIR}/lib

# Create the buildlink wrappers before any of the other buildlink targets
# are run, as the wrapper may need to be used in some of those targets.
#
do-buildlink: buildlink-wrappers buildlink-${_BLNK_OPSYS}-wrappers

# Add each of the *-buildlink targets as a prerequisite for the
# buildlink target.  This ensures that the symlinks are created
# before any configure scripts or build commands are called.
#
.for _target_ in ${BUILDLINK_TARGETS}
do-buildlink: ${_target_}
.endfor

# _LT_ARCHIVE_TRANSFORM creates $${dest} from $${file}, where $${file} is
# a libtool archive (*.la).  It allows libtool to properly interact with
# buildlink at link time by linking against the libraries pointed to by
# symlinks in ${BUILDLINK_DIR}.
#
_LT_ARCHIVE_TRANSFORM_SED=						\
	-e "s|$/usr\(/lib/[^ 	]*\.la\)|${BUILDLINK_DIR}\1|g"		\
	-e "s|${LOCALBASE}\(/lib/[^ 	]*\.la\)|${BUILDLINK_DIR}\1|g"	\
	-e "s|${X11BASE}\(/lib/[^ 	]*\.la\)|${BUILDLINK_DIR}\1|g"

_LT_ARCHIVE_TRANSFORM=							\
	${SED} ${_LT_ARCHIVE_TRANSFORM_SED} $${file} > $${dest}

# _BUILDLINK_USE is a macro target that symlinks package files into a new
# hierarchy under ${BUILDLINK_DIR}.
#
# The variables required to be defined to use this target are listed
# below.  <pkgname> refers to the name of the package and should be used
# consistently.
#
# The target that uses this macro target should perform no other actions
# and be named "<pkgname>-buildlink".
#
# BUILDLINK_PREFIX.<pkgname>    installation prefix of the package
#
# BUILDLINK_FILES.<pkgname>     files relative to ${BUILDLINK_PREFIX.<pkgname>}
#                               to be symlinked into ${BUILDLINK_DIR};
#                               libtool archive files are automatically
#                               filtered out and not linked
#
# BUILDLINK_TARGETS             targets to be invoked during buildlink;
#                               the targets should be appended to this variable
#                               using +=
#
# The variables that may optionally be defined:
#
# BUILDLINK_TRANSFORM.<pkgname> sed arguments used to transform the name of
#                               the source filename into a destination
#                               filename
#
_BUILDLINK_USE: .USE
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cookie=${BUILDLINK_DIR}/.${.TARGET:S/-buildlink//}_buildlink_done; \
	if [ ! -f $${cookie} ]; then					\
		${ECHO_BUILDLINK_MSG} "Linking ${.TARGET:S/-buildlink//} files into ${BUILDLINK_DIR}."; \
		${MKDIR} ${BUILDLINK_DIR};				\
		case "${BUILDLINK_PREFIX.${.TARGET:S/-buildlink//}}" in	\
		${X11BASE})						\
			${RM} -f ${BUILDLINK_X11PKG_DIR} 2>/dev/null;	\
			${LN} -sf ${BUILDLINK_DIR} ${BUILDLINK_X11PKG_DIR}; \
			buildlink_dir="${BUILDLINK_X11PKG_DIR}";		\
			;;						\
		*)							\
			buildlink_dir="${BUILDLINK_DIR}";		\
			;;						\
		esac;							\
		files="${BUILDLINK_FILES.${.TARGET:S/-buildlink//}:S/^/${BUILDLINK_PREFIX.${.TARGET:S/-buildlink//}}\//g}"; \
		for file in $${files}; do				\
			rel_file=`${ECHO} $${file} | ${SED} -e "s|${BUILDLINK_PREFIX.${.TARGET:S/-buildlink//}}/||"`; \
			if [ -z "${BUILDLINK_TRANSFORM.${.TARGET:S/-buildlink//}:Q}" ]; then \
				dest="$${buildlink_dir}/$${rel_file}";	\
			else						\
				dest=`${ECHO} $${buildlink_dir}/$${rel_file} | ${SED} ${BUILDLINK_TRANSFORM.${.TARGET:S/-buildlink//}}`; \
			fi;						\
			if [ -f $${file} ]; then			\
				dir=`${DIRNAME} $${dest}`;		\
				if [ ! -d $${dir} ]; then		\
					${MKDIR} $${dir};		\
				fi;					\
				${RM} -f $${dest};			\
				case $${file} in			\
				*.la)					\
					${_LT_ARCHIVE_TRANSFORM};	\
					;;				\
				*)					\
					${LN} -sf $${file} $${dest};	\
					;;				\
				esac;					\
				if [ -z "${BUILDLINK_TRANSFORM.${.TARGET:S/-buildlink//}:Q}" ]; then \
					${ECHO} $${file} >> $${cookie};	\
				else					\
					${ECHO} "$${file} -> $${dest}" >> $${cookie}; \
				fi;					\
			else						\
				${ECHO} "$${file}: not found" >> $${cookie}; \
			fi;						\
		done;							\
		${TOUCH} ${TOUCH_FLAGS} $${cookie};			\
	fi

# _BLNK_TRANSFORM mini language for translating wrapper arguments into
#	their buildlink equivalents:
#
#	I:src:dst		translates "-Isrc" into "-Idst"
#	II:src:dst1,dst2	translates "-Isrc" into "-Idst1 -Idst2"
#	L:src:dst		translates "-Lsrc" into "-Ldst"
#	LL:src:dst1,dst2	translates "-Lsrc" into "-Ldst1 -Ldst2"
#	l:foo:bar		translates "-lfoo" into "-lbar"
#	r:dir			removes "dir" and "dir/*"
#
_BLNK_TRANSFORM+=	I:${LOCALBASE}:${BUILDLINK_DIR}
_BLNK_TRANSFORM+=	L:${LOCALBASE}:${BUILDLINK_DIR}
_BLNK_TRANSFORM+=	${BUILDLINK_TRANSFORM}
.if defined(USE_X11) || defined(USE_X11BASE) || defined(USE_IMAKE)
.  if !empty(USE_X11_LINKS:M[nN][oO])
_BLNK_TRANSFORM+=	I:${X11BASE}:${BUILDLINK_X11PKG_DIR}
_BLNK_TRANSFORM+=	L:${X11BASE}:${BUILDLINK_X11PKG_DIR}
.  else
_BLNK_TRANSFORM+=	II:${X11BASE}:${BUILDLINK_X11PKG_DIR},${BUILDLINK_X11_DIR}
_BLNK_TRANSFORM+=	LL:${X11BASE}:${BUILDLINK_X11PKG_DIR},${BUILDLINK_X11_DIR}
.  endif
.endif
.for _localbase_ in /usr/pkg /usr/local
.  if ${LOCALBASE} != ${_localbase_}
_BLNK_TRANSFORM+=	r:-I${_localbase_}
_BLNK_TRANSFORM+=	r:-L${_localbase_}
_BLNK_TRANSFORM+=	r:-Wl,-R${_localbase_}
_BLNK_TRANSFORM+=	r:-Wl,-rpath,${_localbase_}
_BLNK_TRANSFORM+=	r:-R${_localbase_}
.  endif
.endfor
#
# Create _BLNK_PROTECT_SED and _BLNK_UNPROTECT_SED variables to protect
# key directories from any argument filtering, as they may be
# subdirectories of ${LOCALBASE}, /usr/pkg, or /usr/local.
#
_BLNK_PROTECT_SED=	# empty
_BLNK_UNPROTECT_SED=	# empty

_BLNK_PROTECT_SED+=	-e "s|${_PKGSRCDIR}|_pKgSrCdIr_|g"
_BLNK_PROTECT_SED+=	-e "s|${BUILDLINK_DIR}|_bUiLdLiNk_dIr_|g"
.if defined(ZOULARISBASE) && (${ZOULARISBASE} != ${LOCALBASE})
_BLNK_PROTECT_SED+=	-e "s|${ZOULARISBASE}|_zOuLaRiSbAsE_|g"
_BLNK_UNPROTECT_SED+=	-e "s|_zOuLaRiSbAsE_|${ZOULARISBASE}|g"
.endif
_BLNK_UNPROTECT_SED+=	-e "s|_bUiLdLiNk_dIr_|${BUILDLINK_DIR}|g"
_BLNK_UNPROTECT_SED+=	-e "s|_pKgSrCdIr_|${_PKGSRCDIR}|g"
#
# Create _BLNK_TRANSFORM_SED.{1,2,3,4} from _BLNK_TRANSFORM.  We must use
# separate variables instead of just one because the contents are too long
# for one variable when we substitute into a shell script later on.
#
_BLNK_TRANSFORM_SED.1+=		${_BLNK_PROTECT_SED}
_BLNK_TRANSFORM_SED.2+=		${_BLNK_PROTECT_SED}
_BLNK_TRANSFORM_SED.3+=		${_BLNK_PROTECT_SED}
_BLNK_TRANSFORM_SED.4+=		${_BLNK_PROTECT_SED}
#
# Change "/usr/lib/libfoo.so"       into "-lfoo",
#        "/usr/pkg/lib/libfoo.so"   into "-L/usr/pkg/lib -lfoo",
#        "/usr/X11R6/lib/libbar.so" into "-L/usr/X11R6/lib -lbar".
#
_BLNK_TRANSFORM_SED.libpath+= \
	-e "s|/usr/lib/lib\([^	 ]*\)\.a|-l\1|g"			\
	-e "s|/usr/lib/lib\([^	 ]*\)\.so|-l\1|g"
_BLNK_TRANSFORM_SED.libpath+= \
	-e "s|\(${LOCALBASE}/[^	 ]*\)/lib\([^	 ]*\)\.a|-L\1 -l\2|g"	\
	-e "s|\(${LOCALBASE}/[^	 ]*\)/lib\([^	 ]*\)\.so|-L\1 -l\2|g"
_BLNK_TRANSFORM_SED.libpath+= \
	-e "s|\(${X11BASE}/[^	 ]*\)/lib\([^	 ]*\)\.a|-L\1 -l\2|g"	\
	-e "s|\(${X11BASE}/[^	 ]*\)/lib\([^	 ]*\)\.so|-L\1 -l\2|g"
_BLNK_TRANSFORM_SED.1+=		${_BLNK_TRANSFORM_SED.libpath}
_BLNK_UNTRANSFORM_SED.1+=	${_BLNK_TRANSFORM_SED.libpath}
#
# Transform "I:/usr/pkg:/buildlink" into:
#	-e "s|-I/usr/pkg |-I/buildlink |g"
#	-e "s|-I/usr/pkg$|-I/buildlink|g"
#	-e "s|-I/usr/pkg/\([^	 ]*\)|-I/buildlink/\1|g"
#
.for _transform_ in ${_BLNK_TRANSFORM:MI\:*\:*}
_BLNK_TRANSFORM_SED.I+= \
	-e "s|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\1/} |-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\2/} |g" \
	-e "s|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\1/}$$|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\2/}|g" \
	-e "s|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\1/}/\([^	 ]*\)|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\2/}/\1|g"
_BLNK_UNTRANSFORM_SED.I+= \
	-e "s|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\2/} |-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\1/} |g" \
	-e "s|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\2/}$$|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\1/}|g" \
	-e "s|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\2/}/\([^	 ]*\)|-I${_transform_:C/^I\:([^\:]*)\:([^\:]*)$/\1/}/\1|g"
.endfor
_BLNK_TRANSFORM_SED.2+=		${_BLNK_TRANSFORM_SED.I}
_BLNK_UNTRANSFORM_SED.2+=	${_BLNK_UNTRANSFORM_SED.I}
#
# Transform "II:/usr/X11R6:/buildlink,/x11-links" into:
#	-e "s|-I/usr/X11R6 |-I/buildlink -I/x11-links |g"
#	-e "s|-I/usr/X11R6$|-I/buildlink -I/x11-links|g"
#	-e "s|-I/usr/X11R6/\([^	 ]*\)|-I/buildlink/\1 -I/x11-links/\1|g"
#
.for _transform_ in ${_BLNK_TRANSFORM:MII\:*\:*,*}
_BLNK_TRANSFORM_SED.II+= \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/} |-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/} -I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/} |g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}$$|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/} -I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}|g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}/\([^	 ]*\)|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/}/\1 -I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}/\1|g"
_BLNK_UNTRANSFORM_SED.II+= \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/} |-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/} |g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/} |-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/} |g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/}$$|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}|g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}$$|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}|g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/}/\([^	 ]*\)|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}/\1|g" \
	-e "s|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}/\([^	 ]*\)|-I${_transform_:C/^II\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}/\1|g"
.endfor
_BLNK_TRANSFORM_SED.2+=		${_BLNK_TRANSFORM_SED.II}
_BLNK_UNTRANSFORM_SED.2+=	${_BLNK_UNTRANSFORM_SED.II}
#
# Transform "L:/usr/pkg:/buildlink" into:
#	-e "s|-L/usr/pkg |-L/buildlink |g"
#	-e "s|-L/usr/pkg$|-L/buildlink|g"
#	-e "s|-L/usr/pkg/\([^	 ]*\)|-L/buildlink/\1|g"
#
.for _transform_ in ${_BLNK_TRANSFORM:ML\:*\:*}
_BLNK_TRANSFORM_SED.L+= \
	-e "s|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\1/} |-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\2/} |g" \
	-e "s|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\1/}$$|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\2/}|g" \
	-e "s|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\1/}/\([^	 ]*\)|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\2/}/\1|g"
_BLNK_UNTRANSFORM_SED.L+= \
	-e "s|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\2/} |-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\1/} |g" \
	-e "s|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\2/}$$|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\1/}|g" \
	-e "s|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\2/}/\([^	 ]*\)|-L${_transform_:C/^L\:([^\:]*)\:([^\:]*)$/\1/}/\1|g"
.endfor
_BLNK_TRANSFORM_SED.2+=		${_BLNK_TRANSFORM_SED.L}
_BLNK_UNTRANSFORM_SED.2+=	${_BLNK_UNTRANSFORM_SED.L}
#
# Transform "LL:/usr/X11R6:/buildlink,/x11-links" into:
#	-e "s|-L/usr/X11R6 |-L/buildlink -L/x11-links |g"
#	-e "s|-L/usr/X11R6$|-L/buildlink -L/x11-links|g"
#	-e "s|-L/usr/X11R6/\([^  ]*\)|-L/buildlink/\1 -L/x11-links/\1|g"
#
.for _transform_ in ${_BLNK_TRANSFORM:MLL\:*\:*,*}
_BLNK_TRANSFORM_SED.LL+= \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/} |-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/} -L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/} |g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}$$|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/} -L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}|g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}/\([^	 ]*\)|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/}/\1 -L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}/\1|g"
_BLNK_UNTRANSFORM_SED.LL+= \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/} |-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/} |g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/} |-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/} |g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/}$$|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}|g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}$$|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}|g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\2/}/\([^	 ]*\)|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}/\1|g" \
	-e "s|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\3/}/\([^	 ]*\)|-L${_transform_:C/^LL\:([^\:]*)\:([^\:]*),([^\:]*)$/\1/}/\1|g"
.endfor
_BLNK_TRANSFORM_SED.2+=		${_BLNK_TRANSFORM_SED.LL}
_BLNK_UNTRANSFORM_SED.2+=	${_BLNK_UNTRANSFORM_SED.LL}
#
# Transform "l:foo:bar" into:
#	-e "s|-lfoo |-lbar |g"
#	-e "s|-lfoo$|-lbar|g"
#
.for _transform_ in ${_BLNK_TRANSFORM:Ml\:*}
_BLNK_TRANSFORM_SED.l+= \
	-e "s|-l${_transform_:C/^l\:([^\:]*)\:([^\:]*)$/\1/} |-l${_transform_:C/^l\:([^\:]*)\:([^\:]*)$/\2/} |g" \
	-e "s|-l${_transform_:C/^l\:([^\:]*)\:([^\:]*)$/\1/}$$|-l${_transform_:C/^l\:([^\:]*)\:([^\:]*)$/\2/}|g"
.endfor
_BLNK_TRANSFORM_SED.3+=		${_BLNK_TRANSFORM_SED.l}
_BLNK_UNTRANSFORM_SED.3+=	${_BLNK_TRANSFORM_SED.l}
#
# Fix up references to the x11-links directory.
#
.if defined(USE_X11) || defined(USE_X11BASE) || defined(USE_IMAKE)
_BLNK_TRANSFORM_SED.4+= \
	-e "s|${BUILDLINK_DIR}/\(${BUILDLINK_X11_DIR:S/^${LOCALBASE}\///}\)|${LOCALBASE}/\1|g"
_BLNK_UNTRANSFORM_SED.4+= \
	-e "s|${BUILDLINK_DIR}/\(${BUILDLINK_X11_DIR:S/^${LOCALBASE}\///}\)|${LOCALBASE}/\1|g"
.endif
#
# Transform "r:-I/usr/local" into:
#	-e "s|-I/usr/local ||g"
#	-e "s|-I/usr/local$||g"
#	-e "s|-I/usr/local/\([^	 ]*\)||g"
#
.for _transform_ in ${_BLNK_TRANSFORM:Mr\:*}
_BLNK_TRANSFORM_SED.r+= \
	-e "s|${_transform_:S/^r://} ||g"				\
	-e "s|${_transform_:S/^r://}$$||g"				\
	-e "s|${_transform_:S/^r://}/[^	 ]*||g"
.endfor
_BLNK_TRANSFORM_SED.4+=		${_BLNK_TRANSFORM_SED.r}
_BLNK_UNTRANSFORM_SED.4+=	${_BLNK_TRANSFORM_SED.r}
#
# Remove -Wl,-R* and *-rpath* if _USE_RPATH != "yes"
#
.if defined(_USE_RPATH) && empty(_USE_RPATH:M[yY][eE][sS])
_BLNK_TRANSFORM_SED.4+= \
	-e "s|-Wl,-R/[^ 	]*||g"					\
	-e "s|-R/[^ 	]*||g"						\
	-e "s|-Wl,-rpath,[^ 	]*||g"
_BLNK_UNTRANSFORM_SED.4+= \
	-e "s|-Wl,-R/[^ 	]*||g"					\
	-e "s|-R/[^ 	]*||g"						\
	-e "s|-Wl,-rpath,[^ 	]*||g"
.endif
#
# Explicitly remove "-I/usr/include" and "-L/usr/lib" as they're redundant.
#
_BLNK_TRANSFORM_SED.4+= \
	-e "s|-I/usr/include ||g"					\
	-e "s|-I/usr/include$$||g"					\
	-e "s|-L/usr/lib ||g"						\
	-e "s|-L/usr/lib$$||g"
_BLNK_UNTRANSFORM_SED.4+= \
	-e "s|-I/usr/include ||g"					\
	-e "s|-I/usr/include$$||g"					\
	-e "s|-L/usr/lib ||g"						\
	-e "s|-L/usr/lib$$||g"

_BLNK_TRANSFORM_SED.1+=		${_BLNK_UNPROTECT_SED}
_BLNK_TRANSFORM_SED.2+=		${_BLNK_UNPROTECT_SED}
_BLNK_TRANSFORM_SED.3+=		${_BLNK_UNPROTECT_SED}
_BLNK_TRANSFORM_SED.4+=		${_BLNK_UNPROTECT_SED}

_BLNK_CHECK_IS_TEXT_FILE?= \
	${FILE_CMD} $${file} | ${EGREP} "(shell script|text)" >/dev/null 2>&1

# _BUILDLINK_SUBST_USE is a make macro that executes code to do general text
# replacement in files in ${WRKSRC}.  The following variables are used:
#
# BUILDLINK_SUBST_MESSAGE.<package>	message to display, noting what is
#					being substituted
#                                       
# BUILDLINK_SUBST_FILES.<package>	files on which to run the substitution;
#					these are relative to ${WRKSRC}
#
# BUILDLINK_SUBST_SED.<package>		sed(1) substitution expression to run
#					on the specified files.
#
# The _BUILDLINK_SUBST_USE macro code will try to verify that a file is a text
# file before attempting any substitutions.
#
_BUILDLINK_SUBST_USE: .USE
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cookie=${BUILDLINK_DIR}/.${.TARGET:S/-buildlink-subst//:S/-/_/g}_buildlink_subst_done; \
	if [ ! -f $${cookie} ]; then					\
		${MKDIR} ${BUILDLINK_DIR};				\
		if [ -n "${BUILDLINK_SUBST_SED.${.TARGET:S/-buildlink-subst//}:C/[ 	]//g:Q}" ]; then \
			cd ${WRKSRC};					\
			files="${BUILDLINK_SUBST_FILES.${.TARGET:S/-buildlink-subst//}}"; \
			if [ -n "$${files}" ]; then			\
				${ECHO_BUILDLINK_MSG} ${BUILDLINK_SUBST_MESSAGE.${.TARGET:S/-buildlink-subst//}}; \
				cd ${WRKSRC};				\
				for file in $${files}; do		\
					if ${_BLNK_CHECK_IS_TEXT_FILE}; then \
						${SED}  ${BUILDLINK_SUBST_SED.${.TARGET:S/-buildlink-subst//}} \
							${BUILDLINK_SUBST_SED.1.${.TARGET:S/-buildlink-subst//}} \
							${BUILDLINK_SUBST_SED.2.${.TARGET:S/-buildlink-subst//}} \
							${BUILDLINK_SUBST_SED.3.${.TARGET:S/-buildlink-subst//}} \
							${BUILDLINK_SUBST_SED.4.${.TARGET:S/-buildlink-subst//}} \
							$${file} > $${file}.modified; \
						if [ -x $${file} ]; then \
							${CHMOD} +x $${file}.modified; \
						fi;			\
						if ! ${CMP} -s $${file} $${file}.modified; then \
							${MV} -f $${file}.modified $${file}; \
							${ECHO} $${file} >> $${cookie}; \
						fi;			\
					fi;				\
				done;					\
			fi;						\
		fi;							\
	fi

REPLACE_BUILDLINK_PATTERNS?=	# empty
_REPLACE_BUILDLINK_PATTERNS=	${REPLACE_BUILDLINK_PATTERNS}
_REPLACE_BUILDLINK_PATTERNS+=	*-config
_REPLACE_BUILDLINK_PATTERNS+=	*Conf.sh
_REPLACE_BUILDLINK_PATTERNS+=	*.pc
_REPLACE_BUILDLINK_PATTERNS_FIND= \
	\( ${_REPLACE_BUILDLINK_PATTERNS:S/$/!/:S/^/-o -name !/:S/!/"/g:S/-o//1} \)

REPLACE_BUILDLINK?=		# empty
_REPLACE_BUILDLINK= \
	${REPLACE_BUILDLINK}						\
	`${FIND} . ${_REPLACE_BUILDLINK_PATTERNS_FIND} -print | ${SED} -e 's|^\./||' | ${SORT} -u`

# When "unbuildlinkifying" a file, we must remove references to the
# buildlink directories and change any -llib to the proper replacement
# libraries (-lreadline -> -ledit, etc.).  Redundant -Idir and -Ldir
# options are removed to optimize the resulting file.
#
REPLACE_BUILDLINK_SED?=		# empty
_REPLACE_BUILDLINK_SED=		${REPLACE_BUILDLINK_SED}
_REPLACE_BUILDLINK_SED+=	${LIBTOOL_ARCHIVE_UNTRANSFORM_SED}

BUILDLINK_SUBST_MESSAGE.unbuildlink= \
	"Fixing buildlink references in files-to-be-installed."
BUILDLINK_SUBST_FILES.unbuildlink=	${_REPLACE_BUILDLINK}
BUILDLINK_SUBST_SED.unbuildlink=	${_REPLACE_BUILDLINK_SED}
BUILDLINK_SUBST_SED.1.unbuildlink=	${_BLNK_UNTRANSFORM_SED.1}
BUILDLINK_SUBST_SED.2.unbuildlink=	${_BLNK_UNTRANSFORM_SED.2}
BUILDLINK_SUBST_SED.3.unbuildlink=	${_BLNK_UNTRANSFORM_SED.3}
BUILDLINK_SUBST_SED.4.unbuildlink=	${_BLNK_UNTRANSFORM_SED.4}

post-build: unbuildlink-buildlink-subst
unbuildlink-buildlink-subst: _BUILDLINK_SUBST_USE

.if !defined(USE_LIBTOOL)
BUILDLINK_FAKE_LA=	${TRUE}
.else
#
# Create a fake libtool archive $$lafile that uses the shared libraries 
# named in $$libpattern.
#
BUILDLINK_FAKE_LA=							\
	if [ ! -f $$lafile ]; then					\
		${ECHO_BUILDLINK_MSG} "Creating libtool archive: $$lafile"; \
		case ${OBJECT_FMT} in					\
		Mach-O) _lib=`${LS} -1 $$libpattern | ${HEAD} -1` ;;	\
		*)      _lib=`${LS} -1r $$libpattern | ${HEAD} -1` ;;	\
		esac;							\
		${_BLNK_FAKE_LA} $$_lib > $$lafile;			\
	fi
.endif

# Generate wrapper scripts for the compiler tools that sanitize the
# argument list by converting references to ${LOCALBASE} and ${X11BASE}
# into references to ${BUILDLINK_DIR}, ${BUILDLINK_X11PKG_DIR}, and
# ${BUILDLINK_X11_DIR}.  These wrapper scripts are to be used instead of
# the actual compiler tools when building software.
#
# BUILDLINK_CC, BUILDLINK_LD, etc. are the full paths to the wrapper
#	scripts.
#
# ALIASES.CC, ALIASES.LD, etc. are the other names by which each wrapper
#	may be invoked.
#
_BLNK_WRAPPEES=		AS CC CXX CPP LD
.if defined(USE_FORTRAN)
_BLNK_WRAPPEES+=	FC
.endif
.if defined(USE_LIBTOOL)
PKGLIBTOOL=		${BUILDLINK_LIBTOOL}
.endif
_BLNK_WRAPPEES+=	LIBTOOL
.if defined(USE_X11) || defined(USE_X11BASE) || defined(USE_IMAKE)
IMAKE?=			${X11BASE}/bin/imake
_BLNK_WRAPPEES+=	IMAKE
.endif
_ALIASES.AS=		as
_ALIASES.CC=		cc gcc
_ALIASES.CXX=		c++ g++ CC
_ALIASES.CPP=		cpp
_ALIASES.FC=		f77 g77
_ALIASES.LD=		ld

# On Darwin, protect against using /bin/sh if it's zsh.
.if ${_BLNK_OPSYS} == "Darwin"
.  if exists(/bin/bash)
BUILDLINK_SHELL?=	/bin/bash
.  else
BUILD_DEPENDS+=		bash-[0-9]*:../../shells/bash2
BUILDLINK_SHELL?=	${LOCALBASE}/bin/bash
.  endif
.else
BUILDLINK_SHELL?=	${SH}
.endif

# _BLNK_WRAP_*.<wrappee> variables represent "template methods" of the

# wrapper script that may be customized per wrapper:
#
# _BLNK_WRAP_SETENV.<wrappee> resets the value of CC, CPP, etc. in the
#	configure and make environments (CONFIGURE_ENV, MAKE_ENV) so that
#	they point to the wrappers.
#
# _BLNK_WRAP_{*CACHE*,*LOGIC*}.<wrappee> are parts of the wrapper script
#	system as described in pkgsrc/mk/buildlink2/README.  The files not
#	ending in "-trans" represent pieces of the wrapper script that may
#	be used to form a wrapper that doesn't translate its arguments,
#	and conversely for the files ending in "-trans".  By default, all
#	wrappers use the "-trans" scripts.
#
# _BLNK_WRAP_ENV.<wrappee> consists of shell commands to export a shell
#	environment for the wrappee.
#
# _BLNK_WRAP_SANITIZE_PATH.<wrappee> sets the PATH for calling executables
#	from within the wrapper.  By default, it removes the buildlink
#	directory from the PATH so that sub-invocations of compiler tools
#	will use the wrappees instead of the wrappers.
#
_BLNK_SANITIZED_PATH!=	${ECHO} ${PATH} | ${SED}			\
	-e "s|:${BUILDLINK_DIR}[^:]*||" -e "s|${BUILDLINK_DIR}[^:]*:||"
_BLNK_WRAP_SANITIZE_PATH=		PATH="${_BLNK_SANITIZED_PATH}"
_BLNK_WRAP_ENV?=			${BUILDLINK_WRAPPER_ENV}
_BLNK_WRAP_PRE_CACHE=			${BUILDLINK_DIR}/bin/.pre-cache
_BLNK_WRAP_POST_CACHE=			${BUILDLINK_DIR}/bin/.post-cache
_BLNK_WRAP_CACHE=			${BUILDLINK_DIR}/bin/.cache
_BLNK_WRAP_LOGIC=			${BUILDLINK_DIR}/bin/.logic
_BLNK_WRAP_POST_CACHE_TRANSFORM=	${BUILDLINK_DIR}/bin/.post-cache-trans
_BLNK_WRAP_CACHE_TRANSFORM=		${BUILDLINK_DIR}/bin/.cache-trans
_BLNK_WRAP_LOGIC_TRANSFORM=		${BUILDLINK_DIR}/bin/.logic-trans
_BLNK_WRAP_SPECIFIC_LOGIC=		${BUILDLINK_DIR}/bin/.std-logic
_BLNK_WRAP_LOG=				${BUILDLINK_DIR}/.wrapper.log
_BLNK_LIBTOOL_FIX_LA=			${BUILDLINK_DIR}/bin/.libtool-fix-la
_BLNK_FAKE_LA=				${BUILDLINK_DIR}/bin/.fake-la

.for _wrappee_ in ${_BLNK_WRAPPEES}
#
# _BLNK_WRAPPER_SH.<wrappee> points to the main wrapper script used to
#	generate the wrapper for the wrappee.
#
_BLNK_WRAPPER_SH.${_wrappee_}=	${.CURDIR}/../../mk/buildlink2/wrapper.sh
_BLNK_WRAP_SETENV.${_wrappee_}=	${_wrappee_}="${BUILDLINK_${_wrappee_}:T}"
_BLNK_WRAP_SANITIZE_PATH.${_wrappee_}=	${_BLNK_WRAP_SANITIZE_PATH}
_BLNK_WRAP_ENV.${_wrappee_}=		${_BLNK_WRAP_ENV}
_BLNK_WRAP_PRE_CACHE.${_wrappee_}=	${_BLNK_WRAP_PRE_CACHE}
_BLNK_WRAP_POST_CACHE.${_wrappee_}=	${_BLNK_WRAP_POST_CACHE_TRANSFORM}
_BLNK_WRAP_CACHE.${_wrappee_}=		${_BLNK_WRAP_CACHE_TRANSFORM}
_BLNK_WRAP_LOGIC.${_wrappee_}=		${_BLNK_WRAP_LOGIC_TRANSFORM}
_BLNK_WRAP_SPECIFIC_LOGIC.${_wrappee_}=	${_BLNK_WRAP_SPECIFIC_LOGIC}
.endfor

# Don't bother adding AS, CPP to the configure or make environments as
# adding them seems to break some GNU configure scripts.
#
_BLNK_WRAP_SETENV.AS=		# empty
_BLNK_WRAP_SETENV.CPP=		# empty

# Also override any F77 value in the environment when compiling Fortran
# code.
#
_BLNK_WRAP_SETENV.FC+=		F77="${BUILDLINK_FC:T}"

# Don't override the default LIBTOOL setting in the environment, as
# it already correctly points to ${PKGLIBTOOL}, and don't sanitize the PATH
# because we want libtool to invoke the wrapper scripts, too.
#
_BLNK_WRAP_SETENV.LIBTOOL=	# empty
_BLNK_WRAPPER_SH.LIBTOOL=	${.CURDIR}/../../mk/buildlink2/libtool.sh
_BLNK_WRAP_SANITIZE_PATH.LIBTOOL=	# empty

# We need to "unbuildlinkify" any libtool archives.
_BLNK_WRAP_LT_UNTRANSFORM_SED=		${_REPLACE_BUILDLINK_SED}

# The ld wrapper script accepts "-Wl,*" arguments.
_BLNK_WRAP_SPECIFIC_LOGIC.LD=	${BUILDLINK_DIR}/bin/.ld-logic

# Don't transform the arguments for imake, which uses the C preprocessor
# to generate Makefiles, so that imake will find its config files.
#
.if defined(USE_X11) || defined(USE_X11BASE) || defined(USE_IMAKE)
_BLNK_WRAP_PRE_CACHE.IMAKE=	${_BLNK_WRAP_PRE_CACHE}
_BLNK_WRAP_POST_CACHE.IMAKE=	${_BLNK_WRAP_POST_CACHE}
_BLNK_WRAP_CACHE.IMAKE=		${_BLNK_WRAP_CACHE}
_BLNK_WRAP_LOGIC.IMAKE=		${_BLNK_WRAP_LOGIC}
.endif

buildlink-wrappers: ${_BLNK_WRAP_CACHE}
buildlink-wrappers: ${_BLNK_WRAP_CACHE_TRANSFORM}
buildlink-wrappers: ${_BLNK_WRAP_LOGIC}
buildlink-wrappers: ${_BLNK_WRAP_LOGIC_TRANSFORM}
buildlink-wrappers: ${_BLNK_LIBTOOL_FIX_LA}
buildlink-wrappers: ${_BLNK_FAKE_LA}

.for _wrappee_ in ${_BLNK_WRAPPEES}
CONFIGURE_ENV+=	${_BLNK_WRAP_SETENV.${_wrappee_}}
MAKE_ENV+=	${_BLNK_WRAP_SETENV.${_wrappee_}}

BUILDLINK_${_wrappee_}=	\
	${BUILDLINK_DIR}/bin/${${_wrappee_}:T:C/^/_asdf_/1:M_asdf_*:S/^_asdf_//}

_BLNK_WRAPPER_TRANSFORM_SED.${_wrappee_}=				\
	-e "s|@BUILDLINK_DIR@|${BUILDLINK_DIR}|g"			\
	-e "s|@BUILDLINK_SHELL@|${BUILDLINK_SHELL}|g"			\
	-e "s|@CAT@|${CAT:Q}|g"						\
	-e "s|@ECHO@|${ECHO:Q}|g"					\
	-e "s|@SED@|${SED:Q}|g"						\
	-e "s|@TOUCH@|${TOUCH:Q}|g"					\
	-e "s|@_BLNK_LIBTOOL_FIX_LA@|${_BLNK_LIBTOOL_FIX_LA:Q}|g"	\
	-e "s|@_BLNK_WRAP_LOG@|${_BLNK_WRAP_LOG:Q}|g"			\
	-e "s|@_BLNK_WRAP_PRE_CACHE@|${_BLNK_WRAP_PRE_CACHE.${_wrappee_}:Q}|g" \
	-e "s|@_BLNK_WRAP_POST_CACHE@|${_BLNK_WRAP_POST_CACHE.${_wrappee_}:Q}|g" \
	-e "s|@_BLNK_WRAP_CACHE@|${_BLNK_WRAP_CACHE.${_wrappee_}:Q}|g"	\
	-e "s|@_BLNK_WRAP_LOGIC@|${_BLNK_WRAP_LOGIC.${_wrappee_}:Q}|g"	\
	-e "s|@_BLNK_WRAP_SPECIFIC_LOGIC@|${_BLNK_WRAP_SPECIFIC_LOGIC.${_wrappee_}:Q}|g" \
	-e "s|@_BLNK_WRAP_ENV@|${_BLNK_WRAP_ENV.${_wrappee_}:Q}|g"	\
	-e "s|@_BLNK_WRAP_SANITIZE_PATH@|${_BLNK_WRAP_SANITIZE_PATH.${_wrappee_}:Q}|g"

buildlink-wrappers: ${BUILDLINK_${_wrappee_}}
.if !target(${BUILDLINK_${_wrappee_}})
${BUILDLINK_${_wrappee_}}:						\
		${_BLNK_WRAPPER_SH.${_wrappee_}}			\
		${_BLNK_WRAP_PRE_CACHE.${_wrappee_}}			\
		${_BLNK_WRAP_POST_CACHE.${_wrappee_}}			\
		${_BLNK_WRAP_SPECIFIC_LOGIC.${_wrappee_}}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_BUILDLINK_MSG}		\
		"Creating wrapper: ${.TARGET}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	wrappee="${${_wrappee_}:C/^/_asdf_/1:M_asdf_*:S/^_asdf_//}";	\
	case $${wrappee} in						\
	/*)	absdir=;						\
		;;							\
	*)	OLDIFS="$$IFS";						\
		IFS=":";						\
		for dir in $${PATH}; do					\
			case $${dir} in					\
			*${BUILDLINK_DIR}*)				\
				;;					\
			*)	if [ -x $${dir}/$${wrappee} ]; then	\
					absdir=$${dir}/;		\
					wrappee=$${absdir}$${wrappee};	\
					break;				\
				fi;					\
				;;					\
			esac;						\
		done;							\
		IFS="$$OLDIFS";						\
		if [ ! -x "$${wrappee}" ]; then				\
			${ECHO_BUILDLINK_MSG} "$${wrappee}: No such file"; \
			exit 1;						\
		fi;							\
		;;							\
	esac;								\
	${MKDIR} ${.TARGET:H};						\
	${CAT} ${_BLNK_WRAPPER_SH.${_wrappee_}}	|			\
	${SED}	${_BLNK_WRAPPER_TRANSFORM_SED.${_wrappee_}}		\
		-e "s|@WRAPPEE@|$${absdir}${${_wrappee_}:Q}|g"		\
		> ${.TARGET};						\
	${CHMOD} +x ${.TARGET}
.endif

.  for _alias_ in ${_ALIASES.${_wrappee_}:S/^/${BUILDLINK_DIR}\/bin\//}
.    if !target(${_alias_})
buildlink-wrappers: ${_alias_}
${_alias_}: ${BUILDLINK_${_wrappee_}}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_BUILDLINK_MSG}		\
		"Linking wrapper: ${.TARGET}"
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${LN} -f ${BUILDLINK_${_wrappee_}} ${.TARGET}
.    endif
.  endfor # _alias_
.endfor   # _wrappee_

# OS-specific overrides for buildlink2 wrappers
#
_BLNK_WRAPPEES.SunOS?=	CC CXX
SUNWSPROBASE?=		/opt/SUNWspro
CC.SunOS?=		${SUNWSPROBASE}/bin/cc
CXX.SunOS?=		${SUNWSPROBASE}/bin/CC

buildlink-${_BLNK_OPSYS}-wrappers: buildlink-wrappers
.for _wrappee_ in ${_BLNK_WRAPPEES.${_BLNK_OPSYS}}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -x "${${_wrappee_}.${_BLNK_OPSYS}}" ]; then		\
		wrapper="${BUILDLINK_DIR}/bin/${${_wrappee_}.${_BLNK_OPSYS}:T}"; \
		${ECHO_BUILDLINK_MSG}					\
			"Creating ${_BLNK_OPSYS} wrapper: $${wrapper}";	\
		${RM} -f $${wrapper};					\
		${CAT} ${_BLNK_WRAPPER_SH.${_wrappee_}} |		\
		${SED}	${_BLNK_WRAPPER_TRANSFORM_SED.${_wrappee_}}	\
			-e "s|@WRAPPEE@|${${_wrappee_}.${_BLNK_OPSYS}}|g" \
		> $${wrapper};						\
		${CHMOD} +x $${wrapper};				\
		for file in ${_ALIASES.${_wrappee_}:S/^/${BUILDLINK_DIR}\/bin\//}; do \
			if [ "$${file}" != "$${wrappee}" ]; then	\
				${TOUCH} $${file};			\
			fi;						\
		done;							\
	fi
.endfor

${_BLNK_WRAP_PRE_CACHE}: ${.CURDIR}/../../mk/buildlink2/pre-cache
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${SED}				\
		-e "s|@WRKDIR@|${WRKDIR}|g"				\
		-e "s|@BUILDLINK_DIR@|${BUILDLINK_DIR}|g"		\
		-e "s|@BUILDLINK_X11_DIR@|${BUILDLINK_X11_DIR}|g"	\
		-e "s|@BUILDLINK_X11PKG_DIR@|${BUILDLINK_X11PKG_DIR}|g"		\
		${.ALLSRC} > ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

${_BLNK_WRAP_POST_CACHE}: ${.CURDIR}/../../mk/buildlink2/post-cache
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${SED}				\
		-e "s|@LOCALBASE@|${LOCALBASE}|g"			\
		-e "s|@X11BASE@|${X11BASE}|g"				\
		-e 's|@ECHO@|${ECHO}|g'					\
		-e 's|@_BLNK_TRANSFORM_SED.1@||g'			\
		-e 's|@_BLNK_TRANSFORM_SED.2@||g'			\
		-e 's|@_BLNK_TRANSFORM_SED.3@||g'			\
		-e 's|@_BLNK_TRANSFORM_SED.4@||g'			\
		${.ALLSRC} > ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

${_BLNK_WRAP_POST_CACHE_TRANSFORM}: ${.CURDIR}/../../mk/buildlink2/post-cache
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${SED}				\
		-e "s|@LOCALBASE@|${LOCALBASE}|g"			\
		-e "s|@X11BASE@|${X11BASE}|g"				\
		-e 's|@ECHO@|${ECHO}|g'					\
		-e 's|@_BLNK_TRANSFORM_SED.1@|${_BLNK_TRANSFORM_SED.1:Q}|g' \
		-e 's|@_BLNK_TRANSFORM_SED.2@|${_BLNK_TRANSFORM_SED.2:Q}|g' \
		-e 's|@_BLNK_TRANSFORM_SED.3@|${_BLNK_TRANSFORM_SED.3:Q}|g' \
		-e 's|@_BLNK_TRANSFORM_SED.4@|${_BLNK_TRANSFORM_SED.4:Q}|g' \
		${.ALLSRC} > ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

${_BLNK_WRAP_CACHE}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_ARGS} ${.TARGET}

${_BLNK_WRAP_CACHE_TRANSFORM}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_ARGS} ${.TARGET}

${_BLNK_WRAP_LOGIC}:							\
		${_BLNK_WRAP_PRE_CACHE}					\
		${_BLNK_WRAP_POST_CACHE}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${.ALLSRC} > ${.TARGET}

${_BLNK_WRAP_LOGIC_TRANSFORM}:						\
		${_BLNK_WRAP_PRE_CACHE}					\
		${_BLNK_WRAP_POST_CACHE_TRANSFORM}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${.ALLSRC} > ${.TARGET}

${_BLNK_WRAP_SPECIFIC_LOGIC}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_ARGS} ${.TARGET}

${_BLNK_WRAP_SPECIFIC_LOGIC.LD}: ${.CURDIR}/../../mk/buildlink2/ld-logic
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${SED}				\
		-e "s|@ECHO@|${ECHO:Q}|g"				\
		${.ALLSRC} > ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

${_BLNK_LIBTOOL_FIX_LA}: ${.CURDIR}/../../mk/buildlink2/libtool-fix-la
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${SED}				\
		-e "s|@WRKSRC@|${WRKSRC}|g"				\
		-e "s|@BASENAME@|${BASENAME:Q}|g"			\
		-e "s|@CAT@|${CAT:Q}|g"					\
		-e "s|@CP@|${CP:Q}|g"					\
		-e "s|@DIRNAME@|${DIRNAME:Q}|g"				\
		-e "s|@ECHO@|${ECHO:Q}|g"				\
		-e "s|@EGREP@|${EGREP:Q}|g"				\
		-e "s|@MV@|${MV:Q}|g"					\
		-e "s|@RM@|${RM:Q}|g"					\
		-e "s|@SED@|${SED:Q}|g"					\
		-e "s|@TOUCH@|${TOUCH:Q}|g"				\
		-e 's|@_BLNK_WRAP_LT_UNTRANSFORM_SED@|${_BLNK_WRAP_LT_UNTRANSFORM_SED:Q}|g' \
		-e 's|@_BLNK_UNTRANSFORM_SED.1@|${_BLNK_UNTRANSFORM_SED.1:Q}|g' \
		-e 's|@_BLNK_UNTRANSFORM_SED.2@|${_BLNK_UNTRANSFORM_SED.2:Q}|g' \
		-e 's|@_BLNK_UNTRANSFORM_SED.3@|${_BLNK_UNTRANSFORM_SED.3:Q}|g' \
		-e 's|@_BLNK_UNTRANSFORM_SED.4@|${_BLNK_UNTRANSFORM_SED.4:Q}|g' \
		${.ALLSRC} > ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

${_BLNK_FAKE_LA}: ${.CURDIR}/../../mk/buildlink2/fake-la
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${SED}				\
		-e "s|@BUILDLINK_DIR@|${BUILDLINK_DIR}|g"		\
		-e "s|@BUILDLINK_SHELL@|${BUILDLINK_SHELL}|g"		\
		-e "s|@BASENAME@|${BASENAME:Q}|g"			\
		-e "s|@CC@|${BUILDLINK_CC:Q}|g"				\
		-e "s|@CP@|${CP:Q}|g"					\
		-e "s|@DIRNAME@|${DIRNAME:Q}|g"				\
		-e "s|@ECHO@|${ECHO:Q}|g"				\
		-e "s|@EGREP@|${EGREP:Q}|g"				\
		-e "s|@LIBTOOL@|${BUILDLINK_LIBTOOL:Q}|g"		\
		-e "s|@MKDIR@|${MKDIR:Q}|g"				\
		-e "s|@MV@|${MV:Q}|g"					\
		-e "s|@RM@|${RM:Q}|g"					\
		-e "s|@SED@|${SED:Q}|g"					\
		${.ALLSRC} > ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}${MV} -f ${.TARGET}.tmp ${.TARGET}

clear-buildlink-cache: remove-buildlink-cache buildlink-wrappers

remove-buildlink-cache:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${_BLNK_WRAP_CACHE_TRANSFORM}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${_BLNK_WRAP_LOGIC_TRANSFORM}

_BLNK_CHECK_PATTERNS+=	-e "-I${LOCALBASE}/[a-rt-z]"
_BLNK_CHECK_PATTERNS+=	-e "-L${LOCALBASE}/[a-rt-z]"
_BLNK_CHECK_PATTERNS+=	-e "-I${X11BASE}/"
_BLNK_CHECK_PATTERNS+=	-e "-L${X11BASE}/"

buildlink-check:
	@if [ -f ${_BLNK_WRAP_LOG} ]; then				\
		${GREP} ${_BLNK_CHECK_PATTERNS} ${_BLNK_WRAP_LOG} || ${TRUE}; \
	fi
