# $NetBSD: bsd.pkg.help.mk,v 1.5 2006/10/01 14:52:32 rillig Exp $
#

# This is the integrated pkgsrc online help system. To query for the
# meaning of a variable, run "make help TOPIC=VARNAME". All variables from
# certain pkgsrc Makefile fragments that have inline comments are eligible
# for querying.

.if !defined(_PKGSRC_HELP_MK)
_PKGSRC_HELP_MK=	# defined

_HELP_FILES=		# empty
_HELP_FILES+=		mk/*.mk
_HELP_FILES+=		mk/*/*.mk

_HELP_AWK= \
	BEGIN {								\
		no = 0; yes = 1;					\
		hline = "===============";				\
		hline = hline hline hline hline hline;			\
		found = no; var = no; comment = no; n = 0;		\
		rcsid = "";						\
		last_line_was_rcsid = no;				\
		last_line_was_empty = yes;				\
	}								\
	/./ {								\
		if ($$0 ~ /^\\#.*\$$.*\$$$$/) {				\
			rcsid = $$0;					\
			last_line_was_rcsid = yes;			\
		} else {						\
			if (!(last_line_was_rcsid && $$0 == "\#")) {	\
				lines[n++] = $$0;			\
			}						\
			last_line_was_rcsid = no;			\
		}							\
	}								\
	($$1 == VARNAME"?=") || ($$1 == "\#"VARNAME"=") 		\
	|| ($$1 == "\#" && last_line_was_empty &&			\
	    ($$2 == VARNAME || $$2 == VARNAME":")) {			\
		var = 1;						\
	}								\
	/^\#/ {								\
		comment = 1;						\
	}								\
	/^$$/ {								\
		if (var && comment) {					\
			found = yes;					\
			print hline;					\
			if (rcsid != "") { print rcsid; print "\#"; }	\
			for (i = 0; i < n; i++) { print lines[i]; }	\
		}							\
		var = no; comment = no; n = 0;				\
	}								\
	/./ {								\
		last_line_was_empty = no;				\
	}								\
	/^\\#$$/ || /^$$/ {						\
		last_line_was_empty = yes;				\
	}								\
	END {								\
		if (found) {						\
			print hline;					\
		} else {						\
			print "No help found for " VARNAME ".";		\
		}							\
	}

.if !defined(TOPIC) && defined(VARNAME)
TOPIC=		${VARNAME}
.endif
.if !defined(TOPIC) && defined(topic)
TOPIC=		${topic}
.endif

.PHONY: help
help:
.if !defined(TOPIC)
	@${PRINTF} "usage: %s help topic=<topic>\\n" ${MAKE:Q}
	@${PRINTF} "\\n"
	@${PRINTF} "\\t<topic> may be a variable name or a make target,\\n"
	@${PRINTF} "\\tfor example CONFIGURE_DIRS or patch.\\n"
	@${PRINTF} "\\n"
.else
	${_PKG_SILENT}${_PKG_DEBUG} set -e;				\
	cd ${PKGSRCDIR};						\
	{ for i in ${_HELP_FILES}; do ${CAT} "$$i"; ${ECHO} ""; done; }	\
	| ${AWK} -v VARNAME=${TOPIC} '${_HELP_AWK}'
.endif

.endif
