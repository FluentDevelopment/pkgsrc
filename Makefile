# $NetBSD: Makefile,v 1.52 2003/02/09 14:38:52 wiz Exp $
#

.include "mk/bsd.prefs.mk"

.ifdef SPECIFIC_PKGS
SUBDIR+=	${SITE_SPECIFIC_PKGS}
SUBDIR+=	${HOST_SPECIFIC_PKGS}
SUBDIR+=	${GROUP_SPECIFIC_PKGS}
SUBDIR+=	${USER_SPECIFIC_PKGS}
.else
SUBDIR += archivers
SUBDIR += audio
SUBDIR += benchmarks
SUBDIR += biology
SUBDIR += cad
SUBDIR += chat
SUBDIR += comms
SUBDIR += converters
SUBDIR += cross
SUBDIR += databases
SUBDIR += devel
SUBDIR += editors
SUBDIR += emulators
SUBDIR += finance
SUBDIR += fonts
SUBDIR += games
SUBDIR += graphics
SUBDIR += ham
SUBDIR += inputmethod
SUBDIR += lang
SUBDIR += mail
SUBDIR += math
SUBDIR += mbone
SUBDIR += meta-pkgs
SUBDIR += misc
SUBDIR += net
SUBDIR += news
SUBDIR += parallel
SUBDIR += pkgtools
SUBDIR += print
SUBDIR += security
SUBDIR += shells
SUBDIR += sysutils
SUBDIR += time
SUBDIR += textproc
SUBDIR += wm
SUBDIR += www
SUBDIR += x11
.endif

PKGSRCTOP=	yes


# If PACKAGES is set to the default (${_PKGSRCDIR}/packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.PHONY: README.html
_README_TYPE_FLAG?=	none
README.html: .PRECIOUS
.if ${_README_TYPE_FLAG} == "--ftp" || ${_README_TYPE_FLAG} == "--cdrom"
	@if [ -e ${PACKAGES} ]; then					\
		cd ${PACKAGES};						\
		case `pwd` in						\
			${.CURDIR}/packages)				\
				MULTIARCH=;				\
				;;					\
			*)						\
				MULTIARCH=--multi-arch;			\
				;;					\
		esac;							\
		cd ${.CURDIR} ;						\
	fi;								\
	${SETENV} TMPDIR=${TMPDIR:U/tmp}/mkreadme	 		\
		BMAKE=${MAKE} AWK=${AWK} EXPR=${EXPR} 			\
		./mk/scripts/mkreadme --pkgsrc ${.CURDIR} 		\
		--packages ${PACKAGES} ${_README_TYPE_FLAG} $$MULTIARCH \
		--prune 
.else
	@${ECHO} "ERROR:  please do not use the README.html target directly."
	@${ECHO} "        Instead use either the \"readme\" or \"cdrom-readme\""
	@${ECHO} "        target."
	@${FALSE}
.endif

.include "mk/bsd.pkg.subdir.mk"

# the bulk-cache and clean-bulk-cache targets are a global-pkgsrc
# thing and thus it makes sense to run it from the top level pkgsrc
# directory.
.if make(bulk-cache) || make(clean-bulk-cache)
.include "${.CURDIR}/mk/bulk/bsd.bulk-pkg.mk"
# force the setting of _PKGSRCDIR because the way it gets
# set in bsd.prefs.mk is broken if you're in this top level directory
_PKGSRCDIR=${.CURDIR}
.endif

index:
	@${RM} -f ${.CURDIR}/INDEX
	@${MAKE} ${.CURDIR}/INDEX

${.CURDIR}/INDEX:
	@${ECHO} -n "Generating INDEX - please wait.."
	@${MAKE} describe ECHO_MSG="${ECHO} > /dev/null" > ${.CURDIR}/INDEX
	@${ECHO} " Done."

print-index:	${.CURDIR}/INDEX
	@${AWK} -F\| '{ printf("Port:\t%s\nPath:\t%s\nInfo:\t%s\nMaint:\t%s\nIndex:\t%s\nB-deps:\t%s\nR-deps:\t%s\nArch:\t%s\n\n", $$1, $$2, $$4, $$6, $$7, $$8, $$9, $$10); }' < ${.CURDIR}/INDEX

search:	${.CURDIR}/INDEX
.if !defined(key)
	@${ECHO} "The search target requires a keyword parameter,"
	@${ECHO} "e.g.: \"${MAKE} search key=somekeyword\""
.else
	@${GREP} ${key} ${.CURDIR}/INDEX | ${AWK} -F\| '{ printf("Port:\t%s\nPath:\t%s\nInfo:\t%s\nMaint:\t%s\nIndex:\t%s\nB-deps:\t%s\nR-deps:\t%s\nArch:\t%s\n\n", $$1, $$2, $$4, $$6, $$7, $$8, $$9, $$10); }'
.endif

#
# Generate list of all packages by extracting information from
# the category/README.html pages
#
readme-all:
	@if [ -f README-all.html ]; then \
		${MV} README-all.html README-all.html.BAK ; \
	fi
	@${MAKE} README-all.html
	@if ${CMP} -s README-all.html README-all.html.BAK ; then \
		${MV} README-all.html.BAK README-all.html ; \
	else \
		${RM} -f README-all.html.BAK ; \
	fi

README-all.html:
	@${RM} -f $@.new
	@${RM} -f $@.newsorted
	@${ECHO} -n "Processing categories for $@:"
.for category in ${SUBDIR}
	@if [ -f ${category}/README.html ]; then \
		${ECHO} -n ' ${category}' ; \
		${GREP} '^<TR>' ${category}/README.html \
		| ${SED} -e 's|"|"${category}/|' \
		      -e 's| <TD>| <TD>(<A HREF="${category}/README.html">${category}</A>) <TD>|' \
		      -e 's|<TR>|<TR VALIGN=TOP>|' \
		      -e 's|<TD VALIGN=TOP>|<TD>|' \
		>> $@.new ; \
	fi
.endfor
	@${ECHO} "."
	@${SORT} -f -t '">' +2 <$@.new >$@.newsorted
	@${WC} -l $@.newsorted | ${AWK} '{ print $$1 }'  >$@.npkgs
	@${CAT} templates/README.all \
	| ${SED} \
		-e '/%%NPKGS%%/r$@.npkgs' \
		-e '/%%NPKGS%%/d' \
		-e '/%%PKGS%%/r$@.newsorted' \
		-e '/%%PKGS%%/d' \
		> $@
	@${RM} -f $@.npkgs
	@${RM} -f $@.new
	@${RM} -f $@.newsorted

readme-ipv6:
	@if [ -f README-IPv6.html ]; then \
		${MV} README-IPv6.html README-IPv6.html.BAK ; \
	fi
	@${MAKE} README-IPv6.html
	@if ${CMP} -s README-IPv6.html README-IPv6.html.BAK  ; then \
		${MV} README-IPv6.html.BAK README-IPv6.html ; \
	else \
		${RM} -f README-IPv6.html.BAK ; \
	fi

README-IPv6.html:
	@${GREP} -l '^BUILD_DEFS.*=.*USE_INET6' */*/Makefile \
	 | ${SED} s,Makefile,, >$@.pkgs
	@${FGREP} -f $@.pkgs README-all.html | ${SORT} -t/ +1 >$@.trs
	@${CAT} templates/README.ipv6 \
	| ${SED} \
		-e '/%%TRS%%/r$@.trs' \
		-e '/%%TRS%%/d' \
		>$@
	@${RM} $@.trs
	@${RM} $@.pkgs

show-host-specific-pkgs:
	@${ECHO} "HOST_SPECIFIC_PKGS= \\";					\
	${MAKE} show-pkgsrc-dir | ${AWK} '/^===/ { next; } { printf("%s \\\n", $$1) }'; \
	${ECHO} ""
