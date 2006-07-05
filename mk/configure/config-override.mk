# $NetBSD: config-override.mk,v 1.1 2006/07/05 06:09:15 jlam Exp $

######################################################################
### config-{guess,sub,rpath}-override (PRIVATE)
######################################################################
### config-{guess,sub,rpath}-override replace any existing config.guess,
### config.sub, and config-rpath under ${WRKSRC} with the specially-kept
### versions under pkgsrc/mk/gnu-config.
###
do-configure-pre-hook: config-guess-override
do-configure-pre-hook: config-guess-override
.if defined(CONFIG_RPATH_OVERRIDE)
do-configure-pre-hook: config-guess-override
.endif

_OVERRIDE_VAR.guess=	CONFIG_GUESS_OVERRIDE
_OVERRIDE_VAR.sub=	CONFIG_SUB_OVERRIDE
_OVERRIDE_VAR.rpath=	CONFIG_RPATH_OVERRIDE

OVERRIDE_DIRDEPTH.config-guess?=	${OVERRIDE_DIRDEPTH}
OVERRIDE_DIRDEPTH.config-sub?=		${OVERRIDE_DIRDEPTH}
OVERRIDE_DIRDEPTH.config-rpath?=	${OVERRIDE_DIRDEPTH}

.for _sub_ in guess sub rpath
_SCRIPT.config-${_sub_}-override=					\
	${RM} -f $$file;						\
	${LN} -fs ${PKGSRCDIR}/mk/gnu-config/config.${_sub_} $$file

.PHONY: config-${_sub_}-override
config-${_sub_}-override:
	@${STEP_MSG} "Replacing config-* with pkgsrc versions"
.  if defined(${_OVERRIDE_VAR.${_sub_}}) && !empty(${_OVERRIDE_VAR.${_sub_}})
	${_PKG_SILENT}${_PKG_DEBUG}set -e;				\
	cd ${WRKSRC};							\
	for file in ${${_OVERRIDE_VAR.${_sub_}}}; do			\
		${TEST} -f "$$file" || continue;			\
		${_SCRIPT.${.TARGET}};					\
	done
.  else
	${_PKG_SILENT}${_PKG_DEBUG}set -e;				\
	cd ${WRKSRC};							\
	depth=0; pattern=config.${_sub_};				\
	while ${TEST} $$depth -le ${OVERRIDE_DIRDEPTH.config-${_sub_}}; do \
		for file in $$pattern; do				\
			${TEST} -f "$$file" || continue;		\
			${_SCRIPT.${.TARGET}};				\
		done;							\
		depth=`${EXPR} $$depth + 1`; pattern="*/$$pattern";	\
	done
.  endif
.endfor
