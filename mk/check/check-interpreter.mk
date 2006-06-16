# $NetBSD: check-interpreter.mk,v 1.7 2006/06/16 12:03:38 rillig Exp $

CHECK_INTERPRETER?=	no

###########################################################################
# CHECK_INTERPRETER_SKIP is a list of shell globs.  Installed files that
# match these globs are skipped when running the check-interpreter target.
#
CHECK_INTERPRETER_SKIP?=	# empty

_CHECK_INTERP_SKIP_FILTER=	case $$file in
.for _pattern_ in ${CHECK_INTERPRETER_SKIP}
_CHECK_INTERP_SKIP_FILTER+=	${PREFIX}/${_pattern_}|${_pattern_}) continue ;;
.endfor
_CHECK_INTERP_SKIP_FILTER+=	*) ;;
_CHECK_INTERP_SKIP_FILTER+=	esac

######################################################################
### check-interpreter (PRIVATE)
######################################################################
### check-interpreter verifies that the interpreters for all installed
### scripts exist.
###
.PHONY: check-interpreter
check-interpreter: error-check
	@${STEP_MSG} "Checking for non-existent script interpreters"	\
		     "in ${PKGNAME}"
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -e;								\
	${PKG_FILELIST_CMD} | ${SORT} | ${SED} 's,\\,\\\\,g' |		\
	while read file; do						\
		${_CHECK_INTERP_SKIP_FILTER};				\
		if ${TEST} ! -r "$$file"; then				\
			${DELAYED_WARNING_MSG} "[check-interpreter.mk] File \"$$file\" cannot be read."; \
			continue;					\
		fi;							\
		${SHCOMMENT} "[$$file]";				\
		interp=`${SED} -n -e '1s/^#![[:space:]]*\([^[:space:]]*\).*/\1/p' -e '1q' < "$$file"` \
		|| {	${DELAYED_WARNING_MSG} "[check-interpreter.mk] sed(1) failed for \"$$file\"."; \
			continue;					\
		};							\
		case $$interp in					\
		"") continue;						\
		esac;							\
		if ${TEST} ! -f "$$interp"; then			\
			if ${TEST} -x "$$file"; then			\
				${DELAYED_ERROR_MSG} "[check-interpreter.mk] The interpreter \"$$interp\" of \"$$file\" does not exist."; \
			else						\
				${DELAYED_WARNING_MSG} "[check-interpreter.mk] The interpreter \"$$interp\" of \"$$file\" does not exist."; \
			fi;						\
		fi;							\
	done
.endif
