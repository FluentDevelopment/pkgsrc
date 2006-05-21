# $NetBSD: bsd.pkg.check.mk,v 1.33 2006/05/21 13:24:44 rillig Exp $
#
# This Makefile fragment is included by bsd.pkg.mk and defines the
# relevant variables and targets for the various install-time "check"
# targets.
#
# The following variables may be set by the user and control which
# checks are run:
#
#    CHECK_FILES causes the extra or missing file checks to be run if
#	it is any value other than "no".  Defaults to "no".
#
#    CHECK_FILES_STRICT makes the file checks very strict on errors if
#	it is any value other than "no".  Defaults to "no".
#
#    CHECK_WRKREF is a list of options that trigger the checks for
#	${WRKDIR} or ${TOOLS_DIR} in the package's installed files.
#	Valid values are "work", which checks for ${WRKDIR}, and
#	"tools", which checks for ${TOOLS_DIR}.  Defaults to "no".
#
#    CHECK_INTERPRETER can be set to "yes" to check that installed
#	#!-scripts will find their interpreter.
#
# The following targets are defined by bsd.pkg.check.mk:
#
#    check-files-pre & check-files-post generate the list of files on the
#	filesystem just before and just after the package's files are
#	installed.
#
#    check-files compares the "pre" and "post" file lists to determine
#	if there are any extra or missing files installed by the
#	package.
#
#    check-wrkref checks whether a package's installed files contain
#	references to ${WRKDIR}.
#
#    check-interpreter checks whether a script's interpreter exists.
#

# For PKG_DEVELOPERs, cause some checks to be run automatically by default.
.if defined(PKG_DEVELOPER)
CHECK_WRKREF?=		tools
CHECK_FILES?=		yes
.endif

CHECK_FILES?=		no
CHECK_FILES_STRICT?=	no
CHECK_WRKREF?=		no
CHECK_INTERPRETER?=	no

USE_TOOLS+=		awk cat cmp diff echo find grep rm sed test	\
			touch true

###########################################################################
### check-files ###########################################################
###########################################################################

###########################################################################
# CHECK_FILES_SKIP is a list of file names that will be skipped when
# analyzing file lists in the check-files target.  This is useful to
# avoid getting errors triggered by changes in directories not really
# handled by pkgsrc.

# Info index files updated when a new info file is added.
.if defined(INFO_FILES)
CHECK_FILES_SKIP+=	${PREFIX}/.*/dir$$$$
.endif

# Perl's perllocal.pod index that is regenerated when a local module
# is added.
#
CHECK_FILES_SKIP+=	${PERL5_INSTALLARCHLIB}/perllocal.pod

# R's index files that are regenerated when a local module
# is added.
#
CHECK_FILES_SKIP+=	${PREFIX}/lib/R/doc/html/packages.html
CHECK_FILES_SKIP+=	${PREFIX}/lib/R/doc/html/search/index.txt

# We don't care about what's under /proc in Linux emulation, which is
# just holds run-time generated data.
#
CHECK_FILES_SKIP+=	${PREFIX}/emul/linux/proc.*

# The reference-count meta-data directory used by the pkginstall framework.
CHECK_FILES_SKIP+=	${PKG_DBDIR}.refcount.*

# File that are outside of ${PREFIX} in directories we already know we'll
# be using for mutable data.
#
.for d in ${MAKE_DIRS} ${OWN_DIRS}
CHECK_FILES_SKIP+=	${d:C/^([^\/])/${PREFIX}\/\1/}.*
.endfor
.for d o g m in ${MAKE_DIRS_PERMS} ${OWN_DIRS_PERMS}
CHECK_FILES_SKIP+=	${d:C/^([^\/])/${PREFIX}\/\1/}.*
.endfor

# Mutable X11 font database files
.if (defined(FONTS_DIRS.ttf) && !empty(FONTS_DIRS.ttf:M*)) || \
    (defined(FONTS_DIRS.type1) && !empty(FONTS_DIRS.type1:M*)) || \
    (defined(FONTS_DIRS.x11) && !empty(FONTS_DIRS.x11:M*))
CHECK_FILES_SKIP+=	${PREFIX}/.*/fonts.alias
CHECK_FILES_SKIP+=	${PREFIX}/.*/fonts.dir
CHECK_FILES_SKIP+=	${PREFIX}/.*/fonts.scale
.endif

# Mutable charset.alias file
CHECK_FILES_SKIP+=	${PREFIX}/lib/charset.alias

_CHECK_FILES_SKIP_FILTER=	${GREP} -vx ${CHECK_FILES_SKIP:@f@-e ${f:Q}@}

###########################################################################
# These are the files generated and used by the check-files implementation
# used across several check-files targets.
#
#    _CHECK_FILES_COOKIE.* are the cookie files that contain the error
#	messages discovered during each stage of file-checking.
#
#    _CHECK_FILES_PRE.* are the file lists generated before any files
#	from the package are installed.
#
#    _CHECK_FILES_POST.* are the file lists generated after all files
#	from the package are installed.
#
# The "pre" and "post" file lists are compared against each other to
# determine if the package is installing files where it shouldn't be.
#
_CHECK_FILES_COOKIE.prefix=	${WRKDIR}/.check_files_prefix_cookie
_CHECK_FILES_PRE.prefix=	${WRKDIR}/.prefix.pre
_CHECK_FILES_POST.prefix=	${WRKDIR}/.prefix.post

_CHECK_FILES_COOKIE.sysconfdir=	${WRKDIR}/.check_files_sysconfdir_cookie
_CHECK_FILES_PRE.sysconfdir=	${WRKDIR}/.sysconfdir.pre
_CHECK_FILES_POST.sysconfdir=	${WRKDIR}/.sysconfdir.post

_CHECK_FILES_COOKIE.varbase=	${WRKDIR}/.check_files_varbase_cookie
_CHECK_FILES_PRE.varbase=	${WRKDIR}/.varbase.pre
_CHECK_FILES_POST.varbase=	${WRKDIR}/.varbase.post

_CHECK_FILES_COOKIES=		# empty
_CHECK_FILES_COOKIES+=		${_CHECK_FILES_COOKIE.prefix}
.if empty(CHECK_FILES_STRICT:M[nN][oO])
_CHECK_FILES_COOKIES+=		${_CHECK_FILES_COOKIE.sysconfdir}
_CHECK_FILES_COOKIES+=		${_CHECK_FILES_COOKIE.varbase}
.endif

###########################################################################
# _CHECK_FILES_PRE holds the list of targets that are built as part of
# building the check-files-pre target.  These targets should cause the
# "pre" file lists to be generated.
#
_CHECK_FILES_PRE=		check-files-pre-message
_CHECK_FILES_PRE+=		${_CHECK_FILES_PRE.prefix}
.if empty(CHECK_FILES_STRICT:M[nN][oO])
_CHECK_FILES_PRE+=		${_CHECK_FILES_PRE.sysconfdir}
_CHECK_FILES_PRE+=		${_CHECK_FILES_PRE.varbase}
.endif

###########################################################################
# _CHECK_FILES_POST holds the list of targets that are built as part of
# building the check-files-post target.  These targets should cause the
# "post" file lists to be generated.
#
_CHECK_FILES_POST=		check-files-post-message
_CHECK_FILES_POST+=		${_CHECK_FILES_POST.prefix}
.if empty(CHECK_FILES_STRICT:M[nN][oO])
_CHECK_FILES_POST+=		${_CHECK_FILES_POST.sysconfdir}
_CHECK_FILES_POST+=		${_CHECK_FILES_POST.varbase}
.endif

###########################################################################
# check-files-pre and check-files-post targets and subtargets
#
.ORDER: ${_CHECK_FILES_PRE}
.ORDER: ${_CHECK_FILES_POST}

.PHONY: check-files-pre check-files-post
check-files-pre: ${_CHECK_FILES_PRE}
check-files-post: ${_CHECK_FILES_POST}

.PHONY: check-files-pre-message check-files-post-message
check-files-pre-message:
	${_PKG_SILENT}${_PKG_DEBUG}${STEP_MSG}				\
		"Generating pre-install file lists"

check-files-post-message:
	${_PKG_SILENT}${_PKG_DEBUG}${STEP_MSG}				\
		"Generating post-install file lists"

${_CHECK_FILES_PRE.prefix} ${_CHECK_FILES_POST.prefix}:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${FIND} ${PREFIX}/. \( -type f -or -type l \) -print 2>/dev/null \
		| ${SED} -e 's,/\./,/,'					\
		| ${_CHECK_FILES_SKIP_FILTER} > ${.TARGET}		\
                || ${TRUE}

${_CHECK_FILES_PRE.sysconfdir} ${_CHECK_FILES_POST.sysconfdir}:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${FIND} ${PKG_SYSCONFDIR}/. -print 2>/dev/null			\
		| ${SED} -e 's,/\./,/,'					\
		| ${_CHECK_FILES_SKIP_FILTER} > ${.TARGET}		\
		|| ${TRUE}

${_CHECK_FILES_PRE.varbase} ${_CHECK_FILES_POST.varbase}:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${FIND} ${VARBASE}/. -print 2>/dev/null				\
		| ${SED} -e 's,/\./,/,'					\
		| ${_CHECK_FILES_SKIP_FILTER} > ${.TARGET}		\
		|| ${TRUE}

###########################################################################
# check-files targets and subtargets
#
.PHONY: check-files-prefix check-files-sysconfdir check-files-varbase
check-files-prefix: ${_CHECK_FILES_COOKIE.prefix}
check-files-sysconfdir: ${_CHECK_FILES_COOKIE.sysconfdir}
check-files-varbase: ${_CHECK_FILES_COOKIE.varbase}

.ORDER: ${_CHECK_FILES_COOKIES}

# The check-files target looks at the cookie files generated by the
# check-files-* subtargets, and if they are non-empty, then they
# contain the error messages collected during the build of each
# subtarget.
#
.PHONY: check-files
check-files: ${_CHECK_FILES_COOKIES}
	${_PKG_SILENT}${_PKG_DEBUG}${STEP_MSG}				\
		"Checking file-check results for ${PKGNAME}"
.for _cookie_ in ${_CHECK_FILES_COOKIES}
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${_cookie_}
.endfor
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${CAT} ${_CHECK_FILES_COOKIES} | ${AWK} 'END { if (NR > 0) exit 1; }'

# Check ${PREFIX} for files which are not listed in the generated ${PLIST}
# and vice-versa.
#
${_CHECK_FILES_COOKIE.prefix}:
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} ! -f ${_CHECK_FILES_PRE.prefix} -o			\
		   ! -f ${_CHECK_FILES_POST.prefix};			\
	then								\
		{ exit 0; };						\
	fi;								\
	f_added=${WRKDIR:Q}/.files.added;				\
	f_deleted=${WRKDIR:Q}/.files.deleted;				\
	f_expected=${WRKDIR:Q}/.files.expected;				\
	f_missing=${WRKDIR:Q}/.files.missing;				\
	f_missing_real=${WRKDIR:Q}/.files.missing.real;			\
	f_missing_skip=${WRKDIR:Q}/.files.missing.skip;			\
	f_extra=${WRKDIR:Q}/.files.extra;				\
	${DIFF} -u ${_CHECK_FILES_PRE.prefix} ${_CHECK_FILES_POST.prefix} \
		> ${WRKDIR}/.files.diff || ${TRUE};			\
	${GREP} '^+/' ${WRKDIR}/.files.diff | ${SED} "s|^+||" | ${SORT}	\
		> $$f_added;						\
	${GREP} '^-/' ${WRKDIR}/.files.diff | ${SED} "s|^-||" | ${SORT}	\
		> $$f_deleted;						\
	${GREP} '^[A-Za-z]' ${PLIST} | ${SED} "s|^|${PREFIX}/|" | ${SORT} \
		> $$f_expected;						\
	${DIFF} -u ${WRKDIR}/.files.expected ${WRKDIR}/.files.added	\
		| ${GREP} '^-[^-]' | ${SED} "s|^-||"			\
		> $$f_missing;						\
	${DIFF} -u ${WRKDIR}/.files.expected ${WRKDIR}/.files.added	\
		| ${GREP} '^+[^+]' | ${SED} "s|^+||"			\
		> $$f_extra;						\
	if ${AWK} 'END { if (NR == 0) exit 1; }' $$f_deleted; then	\
		{ ${ECHO} "*** The following files have been deleted"	\
			  "from ${PREFIX}!";				\
		  ${SED} "s|^|        |" $$f_deleted;			\
		} > ${.TARGET};						\
	fi;								\
	if ${AWK} 'END { if (NR == 0) exit 1; }' $$f_missing $$f_extra;	\
	then								\
		{ ${ECHO} "*** The PLIST does not match installed files!"; \
		  ${CAT} $$f_missing | ${_CHECK_FILES_SKIP_FILTER}	\
			> $$f_missing_real;				\
		  ${DIFF} -u $$f_missing $$f_missing_real		\
			| ${GREP} '^-[^-]' | ${SED} "s|^-||"		\
			> $$f_missing_skip;				\
		  if ${AWK} 'END { if (NR == 0) exit 1; }' $$f_missing_real; \
		  then \
		  	${ECHO} "*** The following files are in the"	\
				"PLIST but not in ${PREFIX}:";		\
			${SED} "s|^|        |" $$f_missing_real;	\
		  fi;							\
		  if ${AWK} 'END { if (NR == 0) exit 1; }' $$f_extra; then \
		  	${ECHO} "*** The following files are in"	\
				"${PREFIX} but not in the PLIST:";	\
			${SED} "s|^|        |" $$f_extra;		\
		  fi;							\
		  if ${AWK} 'END { if (NR == 0) exit 1; }' $$f_missing_skip; \
		  then \
		  	${ECHO} "*** The following files are in both"	\
				"the PLIST and CHECK_FILES_SKIP:";	\
			 ${SED} "s|^|        |" $$f_missing_skip;	\
		  fi;							\
		} >> ${.TARGET};					\
	fi;								\
	${RM} -f ${WRKDIR}/.files.diff $$f_added $$f_deleted		\
		 $$f_expected $$f_missing $$f_extra			\
		 $$f_missing_real $$f_missing_skip
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${.TARGET}

# Check ${SYSCONFDIR} for files which are not in the PLIST and are also
# not copied into place by the INSTALL scripts.
#
${_CHECK_FILES_COOKIE.sysconfdir}:
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} ! -f ${_CHECK_FILES_PRE.sysconfdir} -o		\
		   ! -f ${_CHECK_FILES_POST.sysconfdir};		\
	then								\
		{ exit 0; };						\
	fi;								\
	if ! ${CMP} -s ${_CHECK_FILES_PRE.sysconfdir}			\
		       ${_CHECK_FILES_POST.sysconfdir};			\
	then								\
		{ ${ECHO} "*** The package has modified ${PKG_SYSCONFDIR}" \
			  "contents directly!";				\
		  ${ECHO} "    The offending files/directories are:";	\
		  ${DIFF} -u ${_CHECK_FILES_PRE.sysconfdir}		\
			     ${_CHECK_FILES_POST.sysconfdir}		\
			| ${GREP} '^+[^+]' | ${SED} "s|^+|	|";	\
		} > ${.TARGET};						\
	fi
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${.TARGET}

# Check ${VARBASE} for files which are not in the PLIST and are also
# not created by the INSTALL scripts.
#
${_CHECK_FILES_COOKIE.varbase}:
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} ! -f ${_CHECK_FILES_PRE.varbase} -o			\
		   ! -f ${_CHECK_FILES_POST.varbase};			\
	then								\
		{ exit 0; };						\
	fi;								\
	if ! ${CMP} -s ${_CHECK_FILES_PRE.varbase}			\
		       ${_CHECK_FILES_POST.varbase};			\
	then								\
		{ ${ECHO} "*** The package has modified ${VARBASE}"	\
			  "contents directly!";				\
		  ${ECHO} "    The offending files/directories are:";	\
		  ${DIFF} -u ${_CHECK_FILES_PRE.varbase}		\
			     ${_CHECK_FILES_POST.varbase}		\
			| ${GREP} '^+[^+]' | ${SED} "s|^+|	|";	\
		} > ${.TARGET};						\
	fi
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${.TARGET}

###########################################################################
### check-wrkref ##########################################################
###########################################################################

###########################################################################
# CHECK_WRKREF_SKIP is a list of shell globs.  Installed files that
# match these globs are skipped when running the check-wrkref target.
#
.if make(check-wrkref)
.  if !defined(_CHECK_WRKREF_SKIP_FILTER)
_CHECK_WRKREF_SKIP_FILTER=	${TRUE}
.    if defined(CHECK_WRKREF_SKIP) && !empty(CHECK_WRKREF_SKIP)
_CHECK_WRKREF_SKIP_FILTER=	case "$$file" in
.      for _pattern_ in ${CHECK_WRKREF_SKIP}
_CHECK_WRKREF_SKIP_FILTER+=	${_pattern_}) continue ;;
.      endfor
_CHECK_WRKREF_SKIP_FILTER+=	*) ;;
_CHECK_WRKREF_SKIP_FILTER+=	esac
.    endif
.  endif
MAKEVARS+=	_CHECK_WRKREF_SKIP_FILTER
.else
_CHECK_WRKREF_SKIP_FILTER=	${TRUE}
.endif

_CHECK_WRKREF:=		${CHECK_WRKREF}
.if !empty(_CHECK_WRKREF:Mwork)
_CHECK_WRKREF:=		work		# "work" is the "max" option
.endif

###########################################################################
# check-wrkref target
#
.PHONY: check-wrkref
check-wrkref:
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}${STEP_MSG}				\
		"Checking for work-directory references in ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${PKG_INFO} -qL ${PKGNAME:Q} | ${SORT} |			\
	{ while read file; do						\
		${_CHECK_WRKREF_SKIP_FILTER};				\
		${SHCOMMENT} [$$file];					\
		case ${_CHECK_WRKREF:Mwork:Q}"" in			\
		work)							\
			if ${GREP} -H ${WRKDIR:Q} "$$file" 2>/dev/null; then \
				found=1;				\
			fi;						\
			;;						\
		esac;							\
		case ${_CHECK_WRKREF:Mtools:Q}"" in			\
		tools)							\
			if ${GREP} -H ${TOOLS_DIR:Q} "$$file" 2>/dev/null; then \
				found=1;				\
			fi;						\
			;;						\
		esac;							\
	  done;								\
	  if ${TEST} "$$found" = 1; then				\
		${ECHO} "***";						\
		${ECHO} "*** The above files still have references to the build directory."; \
		${ECHO} "*** This is possibly an error that should be fixed by unwrapping"; \
		${ECHO} "*** the files or adding missing tools to the package makefile!"; \
		${ECHO} "***";						\
		exit 1;							\
	  fi; }
.endif

###########################################################################
### check-interpreter #####################################################
###########################################################################

###########################################################################
# CHECK_INTERPRETER_SKIP is a list of shell globs.  Installed files that
# match these globs are skipped when running the check-interpreter target.
#
CHECK_INTERPRETER_SKIP?=	# empty

_CHECK_INTERP_SKIP_FILTER=	case $$file in
.for _pattern_ in ${CHECK_INTERPRETER_SKIP}
_CHECK_INTERP_SKIP_FILTER+=	${PREFIX:Q}/${_pattern_}|${_pattern_}) continue ;;
.endfor
_CHECK_INTERP_SKIP_FILTER+=	*) ;;
_CHECK_INTERP_SKIP_FILTER+=	esac

###########################################################################
# check-interpreter target
#
.PHONY: check-interpreter
check-interpreter:
	${_PKG_SILENT}${_PKG_DEBUG}${STEP_MSG}				\
		"Checking for non-existent script interpreters in ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${PKG_INFO} -qL ${PKGNAME:Q} | ${SORT} | ${SED} 's,\\,\\\\,g' |	\
	{ exitcode=0;							\
	  while read file; do						\
		${_CHECK_INTERP_SKIP_FILTER};				\
		${SHCOMMENT} "[$$file]";				\
		interp=`${SED} -n -e '1s/^#! *\([^ ]*\).*/\1/p' -e '2q' < "$$file"` \
		|| {	${ECHO} "[bsd.pkg.check.mk] WARNING: sed(1) failed for \"$$file\"." 1>&2; \
			continue;					\
		};							\
		case $$interp in					\
		"") continue;						\
		esac;							\
		if ${TEST} ! -f "$$interp"; then			\
			if ${TEST} -x "$$file"; then			\
				${ECHO} "[bsd.pkg.check.mk] ERROR: The interpreter \"$$interp\" of \"$$file\" does not exist." 1>&2; \
				exitcode=1;				\
			else						\
				${ECHO} "[bsd.pkg.check.mk] WARNING: The interpreter \"$$interp\" of \"$$file\" does not exist." 1>&2; \
			fi;						\
		fi;							\
	  done;								\
	  exit $$exitcode; }
