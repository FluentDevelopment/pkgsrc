# $NetBSD: extract.mk,v 1.7 2006/06/09 13:59:08 jlam Exp $
#
# The following variables may be set by the package Makefile and
# specify how extraction happens:
#
#    EXTRACT_CMD is a shell command list that extracts the contents of
#	an archive named by the variable ${DOWNLOADED_DISTFILE} to the
#	current working directory.  The default is ${EXTRACT_CMD_DEFAULT}.
#
#    EXTRACT_OPTS is a list of options to pass to the "extract" script
#	when using EXTRACT_CMD_DEFAULT.  See the comments at the head of
#	the "extract" script for a definitive list of the available
#	options.  The default list is empty.
#
#    EXTRACT_USING specifies the tool used to extract tar/ustar-format
#	archives when using EXTRACT_CMD_DEFAULT.  The possible values are
#	"gtar", "nbtar", and "pax".  By default, we use the "nbtar" tool
#	(pkgsrc's pax-as-tar).
#
#    EXTRACT_ELEMENTS is a list of files within the distfile to extract
#	when using EXTRACT_CMD_DEFAULT.  By default, this is empty, which
#	causes all files within the archive to be extracted.
#
# The following are read-only variables that may be used within a package
#	Makefile:
#
#    DOWNLOADED_DISTFILE represents the path to the distfile that is
#	currently being extracted, and may be used in custom EXTRACT_CMD
#	overrides, e.g.
#
#	    EXTRACT_CMD= ${TAIL} +25 ${DOWNLOADED_DISTFILE} > foo.pl
#
#    EXTRACT_CMD_DEFAULT uses the "extract" script to unpack archives.  The
#	precise manner in which extraction occurs may be tweaked by setting
#	EXTRACT_OPTS, EXTRACT_USING and EXTRACT_ELEMENTS.
#

_EXTRACT_COOKIE=	${WRKDIR}/.extract_done

######################################################################
### extract (PUBLIC)
######################################################################
### extract is a public target to perform extraction.
###
_EXTRACT_TARGETS+=	checksum
_EXTRACT_TARGETS+=	makedirs
_EXTRACT_TARGETS+=	depends
_EXTRACT_TARGETS+=	tools
_EXTRACT_TARGETS+=	acquire-extract-lock
_EXTRACT_TARGETS+=	${_EXTRACT_COOKIE}
_EXTRACT_TARGETS+=	release-extract-lock

.PHONY: extract
.if !target(extract)
extract: ${_EXTRACT_TARGETS}
.endif

.PHONY: acquire-extract-lock release-extract-lock
acquire-extract-lock: acquire-lock
release-extract-lock: release-lock

.if !exists(${_EXTRACT_COOKIE})
${_EXTRACT_COOKIE}: real-extract
.else
${_EXTRACT_COOKIE}:
	@${DO_NADA}
.endif

######################################################################
### real-extract (PRIVATE)
######################################################################
### real-extract is a helper target onto which one can hook all of the
### targets that do the actual extraction work.
###
_REAL_EXTRACT_TARGETS+=	extract-check-interactive
_REAL_EXTRACT_TARGETS+=	extract-message
_REAL_EXTRACT_TARGETS+=	extract-vars
_REAL_EXTRACT_TARGETS+=	pre-extract
_REAL_EXTRACT_TARGETS+=	do-extract
_REAL_EXTRACT_TARGETS+=	post-extract
_REAL_EXTRACT_TARGETS+=	extract-cookie
_REAL_EXTRACT_TARGETS+=	error-check

.PHONY: real-extract
real-extract: ${_REAL_EXTRACT_TARGETS}

.PHONY: extract-message
extract-message:
	@${PHASE_MSG} "Extracting for ${PKGNAME}"

######################################################################
### extract-check-interactive (PRIVATE)
######################################################################
### extract-check-interactive checks whether we must do an interactive
### extraction or not.
###
extract-check-interactive:
.if !empty(INTERACTIVE_STAGE:Mextract) && defined(BATCH)
	@${ERROR_MSG} "The extract stage of this package requires user interaction"
	@${ERROR_MSG} "Please extract manually with:"
	@${ERROR_MSG} "    \"cd ${.CURDIR} && ${MAKE} extract\""
	@${TOUCH} ${_INTERACTIVE_COOKIE}
	@${FALSE}
.else
	@${DO_NADA}
.endif

######################################################################
### extract-cookie (PRIVATE)
######################################################################
### extract-cookie creates the "extract" cookie file.  The contents
### are the name of the package.
###
.PHONY: extract-cookie
extract-cookie:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_EXTRACT_COOKIE:H}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} ${PKGNAME} >> ${_EXTRACT_COOKIE}

######################################################################
### pre-extract, do-extract, post-extract (PUBLIC, override)
######################################################################
### {pre,do,post}-extract are the heart of the package-customizable
### extract targets, and may be overridden within a package Makefile.
###
.PHONY: pre-extract do-extract post-extract

EXTRACT_USING?=		nbtar
EXTRACT_ELEMENTS?=	# empty

###
### Build the default extraction command
###
_EXTRACT_ENV+=	${EXTRACT_OPTS_BIN:D	EXTRACT_OPTS_BIN=${EXTRACT_OPTS_BIN:Q}}
_EXTRACT_ENV+=	${EXTRACT_OPTS_LHA:D	EXTRACT_OPTS_LHA=${EXTRACT_OPTS_LHA:Q}}
_EXTRACT_ENV+=	${EXTRACT_OPTS_PAX:D	EXTRACT_OPTS_PAX=${EXTRACT_OPTS_PAX:Q}}
_EXTRACT_ENV+=	${EXTRACT_OPTS_RAR:D	EXTRACT_OPTS_RAR=${EXTRACT_OPTS_RAR:Q}}
_EXTRACT_ENV+=	${EXTRACT_OPTS_TAR:D	EXTRACT_OPTS_TAR=${EXTRACT_OPTS_TAR:Q}}
_EXTRACT_ENV+=	${EXTRACT_OPTS_ZIP:D	EXTRACT_OPTS_ZIP=${EXTRACT_OPTS_ZIP:Q}}
_EXTRACT_ENV+=	${EXTRACT_OPTS_ZOO:D	EXTRACT_OPTS_ZOO=${EXTRACT_OPTS_ZOO:Q}}
_EXTRACT_ENV+=	${TOOLS_BZCAT:D		BZCAT=${TOOLS_BZCAT:Q}}
_EXTRACT_ENV+=	${TOOLS_CAT:D		CAT=${TOOLS_CAT:Q}}
_EXTRACT_ENV+=	${TOOLS_CP:D		CP=${TOOLS_CP:Q}}
_EXTRACT_ENV+=	${TOOLS_ECHO:D		ECHO=${TOOLS_ECHO:Q}}
_EXTRACT_ENV+=	${TOOLS_CMDLINE.gzcat:D	GZCAT=${TOOLS_CMDLINE.gzcat:Q}}
_EXTRACT_ENV+=	${TOOLS_LHA:D		LHA=${TOOLS_LHA:Q}}
_EXTRACT_ENV+=	${TOOLS_MKDIR:D		MKDIR=${TOOLS_MKDIR:Q}}
_EXTRACT_ENV+=	${TOOLS_RM:D		RM=${TOOLS_RM:Q}}
_EXTRACT_ENV+=	${TOOLS_PAX:D		PAX=${TOOLS_PAX:Q}}
_EXTRACT_ENV+=	${TOOLS_SH:D		SH=${TOOLS_SH:Q}}
_EXTRACT_ENV+=	${TOOLS_TAR:D		TAR=${TOOLS_TAR:Q}}
_EXTRACT_ENV+=	${TOOLS_TEST:D		TEST=${TOOLS_TEST:Q}}
_EXTRACT_ENV+=	${TOOLS_UNRAR:D		UNRAR=${TOOLS_UNRAR:Q}}
_EXTRACT_ENV+=	${TOOLS_UNZIP_CMD:D	UNZIP_CMD=${TOOLS_UNZIP_CMD:Q}}
_EXTRACT_ENV+=	${TOOLS_UNZOO:D		UNZOO=${TOOLS_UNZOO:Q}}
_EXTRACT_ENV+=	${EXTRACT_ENV}

.if !empty(EXTRACT_USING:Mgtar)
EXTRACT_OPTS+=	${TOOLS_GTAR:D	-t ${TOOLS_GTAR}}
.elif !empty(EXTRACT_USING:Mnbtar)
EXTRACT_OPTS+=	${TOOLS_TAR:D	-t ${TOOLS_TAR}}
.else
EXTRACT_OPTS+=	${TOOLS_PAX:D	-t ${TOOLS_PAX}}
.endif

EXTRACT_CMD_DEFAULT=							\
	${SETENV} ${_EXTRACT_ENV}					\
	${SH} ${PKGSRCDIR}//mk/extract/extract				\
		${EXTRACT_OPTS}						\
		${DOWNLOADED_DISTFILE} ${EXTRACT_ELEMENTS}

EXTRACT_CMD?=	${EXTRACT_CMD_DEFAULT}

DOWNLOADED_DISTFILE=	$${extract_file}

.if !target(do-extract)
do-extract: ${WRKDIR}
.  for __file__ in ${EXTRACT_ONLY}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	extract_file=${_DISTDIR:Q}/${__file__:Q}; export extract_file;	\
	cd ${WRKDIR} && ${EXTRACT_CMD}
.  endfor
.endif

.if !target(pre-extract)
pre-extract:
	@${DO_NADA}
.endif
.if !target(post-extract)
post-extract:
	@${DO_NADA}
.endif
