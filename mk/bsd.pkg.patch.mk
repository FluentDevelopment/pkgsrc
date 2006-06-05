# $NetBSD: bsd.pkg.patch.mk,v 1.23 2006/06/05 22:49:44 jlam Exp $
#
# This Makefile fragment is included by bsd.pkg.mk and defines the
# relevant variables and targets for the "patch" phase.
#
# The following variables may be set in a package Makefile and control
# how pkgsrc patches are applied.
#
#    PATCH_STRIP is a patch(1) argument that sets the pathname strip
#	count to help find the correct files to patch.  See the patch(1)
#	man page for more details.  Defaults to "-p0".
#
#    PATCH_ARGS is the base set of arguments passed to patch(1).
#	The default set of arguments will apply the patches to the
#	files in ${WRKSRC} with any ${PATCH_STRIP} arguments set.
#
# The following variables may be set in a package Makefile and control
# how "distribution" patches are applied.
#
#    PATCHFILES is a list of distribution patches relative to
#	${_DISTDIR} that are applied first to the package.
#
#    PATCH_DIST_STRIP is a patch(1) argument that sets the pathname
#	strip count to help find the correct files to patch.  See the
#	patch(1) man page for more details.  Defaults to "-p0".
#
#    PATCH_DIST_ARGS is the base set of arguments passed to patch(1).
#	The default set of arguments will apply the patches to the
#	files in ${WRKSRC} with any ${PATCH_DIST_STRIP} arguments set.
#
#    PATCH_DIST_CAT is the command that outputs the contents of the
#	"$patchfile" to stdout.  The default value is a command that
#	can output gzipped, bzipped, or plain patches to stdout.
#
#    PATCH_DIST_STRIP.<patchfile>
#    PATCH_DIST_ARGS.<patchfile>
#    PATCH_DIST_CAT.<patchfile>
#	These are versions of the previous three variables which allow
#	for customization of their values for specific patchfiles.
#
# The following variables may be set by the user and affect how patching
# occurs:
#
#    PATCH_DEBUG, if defined, causes the the patch process to be more
#	verbose.
#
#    PATCH_FUZZ_FACTOR is a patch(1) argument that specifies how much
#	fuzz to accept when applying pkgsrc patches.  See the patch(1)
#	man page for more details.  Defaults to "-F0" for zero fuzz.
#
#    LOCALPATCHES is the location of local patches that are maintained
#	in a directory tree reflecting the same hierarchy as the pkgsrc
#	tree, e.g., local patches for www/apache would be found in
#	${LOCALPATCHES}/www/apache.  These patches are applied after
#	the patches in ${PATCHDIR}.
#
# The following targets are defined by bsd.pkg.patch.mk:
#
#    patch is the target that is invoked by the user to perform the
#	"patch" action.
#
#    do-patch is the target that causes the actual patching of the
#	extracted sources to occur during the "patch" phase.  This
#	target may be overridden in a package Makefile.
#
#    {pre,post}-patch are the targets that are invoked before and after
#	do-patch, and may be overridden in a package Makefile.
#

.if (defined(PATCHFILES) && !empty(PATCHFILES)) || \
    (defined(PATCHDIR) && exists(${PATCHDIR})) || \
    (defined(LOCALPATCHES) && exists(${LOCALPATCHES}/${PKGPATH}))
USE_TOOLS+=	patch
.endif

# These tools are used to output the contents of the distribution patches
# to stdout.
#
.if defined(PATCHFILES)
USE_TOOLS+=	cat
.  if !empty(PATCHFILES:M*.Z) || !empty(PATCHFILES:M*.gz)
USE_TOOLS+=	gzcat
.  endif
.  if !empty(PATCHFILES:M*.bz2)
USE_TOOLS+=	bzcat
.  endif
.endif

.if defined(PATCH_DEBUG) || defined(PKG_VERBOSE)
_PATCH_DEBUG=		yes
ECHO_PATCH_MSG?=	${ECHO_MSG}
.else
_PATCH_DEBUG=		no
ECHO_PATCH_MSG?=	${TRUE}
.endif

PATCH_STRIP?=		-p0
.if !empty(_PATCH_DEBUG:M[yY][eE][sS])
PATCH_ARGS?=		-d ${WRKSRC} -E ${PATCH_STRIP}
.else
PATCH_ARGS?=		-d ${WRKSRC} --forward --quiet -E ${PATCH_STRIP}
.endif
.if defined(BATCH)
PATCH_ARGS+=		--batch
.endif
.if defined(_PATCH_CAN_BACKUP) && (${_PATCH_CAN_BACKUP} == "yes")
PATCH_ARGS+=		${_PATCH_BACKUP_ARG} .orig
.endif
PATCH_FUZZ_FACTOR?=	-F0	# Default to zero fuzz

# The following variables control how "distribution" patches are extracted
# and applied to the package sources.
#
# PATCH_DIST_STRIP is a patch option that sets the pathname strip count.
# PATCH_DIST_ARGS is the list of arguments to pass to the patch command.
# PATCH_DIST_CAT is the command that outputs the patch to stdout.
#
# For each of these variables, there is a patch-specific variant that
# may be set, i.e. PATCH_DIST_STRIP.<patch>, PATCH_DIST_ARGS.<patch>,
# PATCH_DIST_CAT.<patch>.
#
PATCH_DIST_STRIP?=		-p0
.for i in ${PATCHFILES}
PATCH_DIST_STRIP.${i:S/=/--/}?=	${PATCH_DIST_STRIP}
.  if defined(PATCH_DIST_ARGS)
PATCH_DIST_ARGS.${i:S/=/--/}?=	${PATCH_DIST_ARGS}
.  elif !empty(_PATCH_DEBUG:M[yY][eE][sS])
PATCH_DIST_ARGS.${i:S/=/--/}?=	-d ${WRKSRC} -E ${PATCH_DIST_STRIP.${i:S/=/--/}}
.  else
PATCH_DIST_ARGS.${i:S/=/--/}?=	-d ${WRKSRC} --forward --quiet -E ${PATCH_DIST_STRIP.${i:S/=/--/}}
.  endif
.endfor
.if defined(BATCH)
PATCH_DIST_ARGS+=		--batch
.  for i in ${PATCHFILES}
PATCH_DIST_ARGS.${i:S/=/--/}+=	--batch
.  endfor
.endif
.if defined(_PATCH_CAN_BACKUP) && (${_PATCH_CAN_BACKUP} == "yes")
PATCH_DIST_ARGS+=		${_PATCH_BACKUP_ARG} .orig_dist
.  for i in ${PATCHFILES}
PATCH_DIST_ARGS.${i:S/=/--/}+=	${_PATCH_BACKUP_ARG} .orig_dist
.  endfor
.endif
PATCH_DIST_CAT?=	{ case $$patchfile in				\
			  *.Z|*.gz) ${GZCAT} $$patchfile ;;		\
			  *.bz2)    ${BZCAT} $$patchfile ;;		\
			  *)	    ${CAT} $$patchfile ;;		\
			  esac; }
.for i in ${PATCHFILES}
PATCH_DIST_CAT.${i:S/=/--/}?=	{ patchfile=${i}; ${PATCH_DIST_CAT}; }
.endfor

_PKGSRC_PATCH_TARGETS=	uptodate-digest
.if defined(PATCHFILES)
_PKGSRC_PATCH_TARGETS+=	distribution-patch-message do-distribution-patch
.endif
.if (defined(PATCHDIR) && exists(${PATCHDIR})) || \
    (defined(LOCALPATCHES) && exists(${LOCALPATCHES}/${PKGPATH}))
_PKGSRC_PATCH_TARGETS+=	pkgsrc-patch-message do-pkgsrc-patch
.endif

.PHONY: do-patch
.if !target(do-patch)
.ORDER: ${_PKGSRC_PATCH_TARGETS}
do-patch: ${_PKGSRC_PATCH_TARGETS}
.endif

_PKGSRC_PATCH_FAIL=							\
if ${TEST} -n ${PKG_OPTIONS:Q}"" ||					\
   ${TEST} -n ${LOCALPATCHES:Q}"" -a -d ${LOCALPATCHES:Q}/${PKGPATH:Q}; then \
	${ECHO} "=========================================================================="; \
	${ECHO};							\
	${ECHO} "Some of the selected build options and/or local patches may be incompatible."; \
	${ECHO} "Please try building with fewer options or patches.";	\
	${ECHO};							\
	${ECHO} "=========================================================================="; \
fi; exit 1

_PATCH_COOKIE_TMP=	${_PATCH_COOKIE}.tmp
_GENERATE_PATCH_COOKIE=	\
	if ${TEST} -f ${_PATCH_COOKIE_TMP:Q}; then			\
		${CAT} ${_PATCH_COOKIE_TMP:Q} >> ${_PATCH_COOKIE:Q};	\
		${RM} -f ${_PATCH_COOKIE_TMP:Q};			\
	else								\
		${TOUCH} ${TOUCH_FLAGS} ${_PATCH_COOKIE:Q};		\
	fi

.PHONY: distribution-patch-message do-distribution-patch

distribution-patch-message:
	@${PHASE_MSG} "Applying distribution patches for ${PKGNAME}"

.if !target(do-distribution-patch)
do-distribution-patch:
.  for i in ${PATCHFILES}
	@${ECHO_PATCH_MSG} "Applying distribution patch ${i}"
	${_PKG_SILENT}${_PKG_DEBUG}cd ${_DISTDIR};			\
	${PATCH_DIST_CAT.${i:S/=/--/}} |				\
	${PATCH} ${PATCH_DIST_ARGS.${i:S/=/--/}}			\
		|| { ${ECHO} "Patch ${i} failed"; ${_PKGSRC_PATCH_FAIL}; }
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} ${i:Q} >> ${_PATCH_COOKIE_TMP:Q}
.  endfor
.endif

_PKGSRC_PATCHES=	# empty
.if defined(PATCHDIR) && exists(${PATCHDIR})
_PKGSRC_PATCHES+=	${PATCHDIR}/patch-*
.endif
.if defined(LOCALPATCHES) && exists(${LOCALPATCHES}/${PKGPATH})
_PKGSRC_PATCHES+=	${LOCALPATCHES}/${PKGPATH}/*
.endif

.PHONY: pkgsrc-patch-message do-pkgsrc-patch

pkgsrc-patch-message:
	@${PHASE_MSG} "Applying pkgsrc patches for ${PKGNAME}"

.if !target(do-pkgsrc-patch)
do-pkgsrc-patch:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	fail=;								\
	patches=${_PKGSRC_PATCHES:Q};					\
	patch_warning() {						\
		${ECHO_MSG} "**************************************";	\
		${ECHO_MSG} "$$1";					\
		${ECHO_MSG} "**************************************";	\
	};								\
	for i in $$patches; do						\
		${TEST} -f "$$i" || continue;				\
		case "$$i" in						\
		*.orig|*.rej|*~)					\
			${STEP_MSG} "Ignoring patchfile $$i";		\
			continue;					\
			;;						\
		${PATCHDIR}/patch-local-*) 				\
			;;						\
		${PATCHDIR}/patch-*) 					\
			if ${TEST} ! -f ${DISTINFO_FILE:Q}; then	\
				patch_warning "Ignoring patch file $$i: distinfo not found"; \
				continue;				\
			fi;						\
			filename=`${BASENAME} $$i`;			\
			algsum=`${AWK} '(NF == 4) && ($$2 == "('$$filename')") && ($$3 == "=") {print $$1 " " $$4}' ${DISTINFO_FILE} || ${TRUE}`; \
			if ${TEST} -z "$$algsum"; then			\
				patch_warning "Ignoring patch file $$i: no checksum found"; \
				continue;				\
			fi;						\
			set -- $$algsum;				\
			alg="$$1";					\
			recorded="$$2";					\
			calcsum=`${SED} -e '/\$$NetBSD.*/d' $$i | ${DIGEST} $$alg`; \
			${ECHO_PATCH_MSG} "=> Verifying $$filename (using digest algorithm $$alg)"; \
			if ${TEST} "$$calcsum" != "$$recorded"; then	\
				patch_warning "Ignoring patch file $$i: invalid checksum"; \
				fail="$$fail $$i";			\
				continue;				\
			fi;						\
			;;						\
		esac;							\
		${ECHO_PATCH_MSG} "Applying pkgsrc patch $$i";		\
		fuzz_flags=;						\
		if ${PATCH} -v >/dev/null 2>&1; then			\
			fuzz_flags=${PATCH_FUZZ_FACTOR:Q};		\
		fi;							\
		if ${PATCH} $$fuzz_flags ${PATCH_ARGS} < $$i; then	\
			${ECHO} "$$i" >> ${_PATCH_COOKIE_TMP:Q};	\
		else							\
			${ECHO_MSG} "Patch $$i failed";			\
			fail="$$fail $$i";				\
		fi;							\
	done;								\
	if ${TEST} -n "$$fail"; then					\
		${ECHO_MSG} "Patching failed due to modified or broken patch file(s):"; \
		for i in $$fail; do					\
			${ECHO_MSG} "	$$i";				\
		done;							\
		${_PKGSRC_PATCH_FAIL};					\
	fi
.endif

_PATCH_COOKIE=		${WRKDIR}/.patch_done

_PATCH_TARGETS+=	extract
_PATCH_TARGETS+=	acquire-patch-lock
_PATCH_TARGETS+=	${_PATCH_COOKIE}
_PATCH_TARGETS+=	release-patch-lock

.ORDER: ${_PATCH_TARGETS}

.PHONY: patch
patch: ${_PATCH_TARGETS}

.PHONY: acquire-patch-lock release-patch-lock
acquire-patch-lock: acquire-lock
release-patch-lock: release-lock

${_PATCH_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-patch PKG_PHASE=patch

_REAL_PATCH_TARGETS+=	patch-message
_REAL_PATCH_TARGETS+=	patch-vars
_REAL_PATCH_TARGETS+=	pre-patch
_REAL_PATCH_TARGETS+=	do-patch
_REAL_PATCH_TARGETS+=	post-patch
_REAL_PATCH_TARGETS+=	patch-cookie

.ORDER: ${_REAL_PATCH_TARGETS}

.PHONY: patch-message
patch-message:
	@${PHASE_MSG} "Patching for ${PKGNAME}"

.PHONY: patch-cookie
patch-cookie:
	${_PKG_SILENT}${_PKG_DEBUG}${_GENERATE_PATCH_COOKIE}

.PHONY: real-patch

real-patch: ${_REAL_PATCH_TARGETS}

.PHONY: pre-patch post-patch
.if !target(pre-patch)
pre-patch:
	@${DO_NADA}
.endif
.if !target(post-patch)
post-patch:
	@${DO_NADA}
.endif
