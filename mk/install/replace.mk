# $NetBSD: replace.mk,v 1.1 2006/06/03 23:11:42 jlam Exp $

######################################################################
### replace (PUBLIC)
######################################################################
### replace is a public target to update a package in-place on the
### system.  It will acquire elevated privileges just-in-time.
###
_REPLACE_TARGETS+=	${_PKGSRC_BUILD_TARGETS}
_REPLACE_TARGETS+=	replace-message
_REPLACE_TARGETS+=	unprivileged-install-hook

.PHONY: replace su-replace
replace: ${_REPLACE_TARGETS} su-target

replace-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Replacing for ${PKGNAME}"
        @${WARNING_MSG} "experimental target - DATA LOSS MAY OCCUR."

su-replace: replace-pkg
MAKEFLAGS.su-replace=	UPDATE_RUNNING=yes

######################################################################
### undo-replace (PUBLIC)
######################################################################
### undo-replace is a public target to undo the effects of the
### "replace" target.  It will acquire elevated privileges just-in-time.
###
.PHONY: undo-replace su-undo-replace
undo-replace: undo-replace-message su-target

undo-replace-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Undoing replacement for ${PKGNAME}"
        @${WARNING_MSG} "experimental target - DATA LOSS MAY OCCUR."

su-undo-replace: undo-replace-pkg
MAKEFLAGS.su-undo-replace=	UPDATE_RUNNING=yes

######################################################################
### replace-pkg (PRIVATE, override)
######################################################################
### replace-pkg updates a package in-place on the system.  This should
### be overridden per package system flavor.
###
.if !target(replace-pkg)
replace-pkg:
	@${DO_NADA}
.endif

######################################################################
### undo-replace-pkg (PRIVATE, override)
######################################################################
### undo-replace-pkg undoes a "make replace".  This should be overridden
### per package system flavor.
###
.if !target(undo-replace-pkg)
undo-replace-pkg:
	@${DO_NADA}
.endif
