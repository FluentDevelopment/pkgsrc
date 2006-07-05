# $NetBSD: check.mk,v 1.2 2006/07/05 09:08:35 jlam Exp $

######################################################################
### check-vulnerable (PUBLIC, pkgsrc/mk/check/check.mk)
######################################################################
### check-vulnerable checks for any vulnerabilities in the package
### without needing audit-packages to be installed.
###
### XXX This should really be invoking audit-packages directly.  Having
### XXX a separately maintained piece of code that inspects the
### XXX vulnerabilities database is poor.
###
.PHONY: check-vulnerable
check-vulnerable:
.if defined(ALLOW_VULNERABLE_PACKAGES)
	@${DO_NADA}
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	vulnfile=${PKGVULNDIR:Q}/pkg-vulnerabilities;			\
	if ${TEST} ! -f "$$vulnfile"; then				\
		${PHASE_MSG} "Skipping vulnerability checks.";		\
		${WARNING_MSG} "No $$vulnfile file found.";		\
		${WARNING_MSG} "To fix, install the pkgsrc/security/audit-packages"; \
		${WARNING_MSG} "package and run: \`\`${LOCALBASE}/sbin/download-vulnerability-list''."; \
		exit 0;							\
	fi;								\
	${PHASE_MSG} "Checking for vulnerabilities in ${PKGNAME}";	\
	conffile=;							\
	for dir in							\
		__dummy							\
		${PKG_SYSCONFDIR.audit-packages:Q}""			\
		${PKG_SYSCONFDIR:Q}"";					\
	do								\
		case $$dir in						\
		/*)	conffile="$$dir/audit-packages.conf"; break ;;	\
		*)	continue ;;					\
		esac;							\
	done;								\
	if ${TEST} -z "$$conffile" -a -f "$$conffile"; then		\
		. $$conffile;						\
	fi;								\
	${SETENV} PKGNAME=${PKGNAME}					\
		  PKGBASE=${PKGBASE}					\
	${AWK} 'BEGIN { exitcode = 0 }					\
		/^$$/ { next }						\
		/^#.*/ { next }						\
		$$1 !~ ENVIRON["PKGBASE"] && $$1 !~ /\{/ { next }	\
		{ s = sprintf("${PKG_ADMIN} pmatch \"%s\" %s && ${ERROR_MSG:S/"/\"/g} \"%s vulnerability in %s - see %s for more information\"", $$1, ENVIRON["PKGNAME"], $$2, ENVIRON["PKGNAME"], $$3); if (system(s) == 0) { print $$1; exitcode += 1 }; } \
		END { exit exitcode }' < $$vulnfile || ${FALSE};	\
	if ${TEST} "$$?" -ne 0; then					\
		${ERROR_MSG} "Define ALLOW_VULNERABLE_PACKAGES if this package is absolutely essential"; \
		${FALSE};						\
	fi
.endif
