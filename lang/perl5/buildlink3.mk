# $NetBSD: buildlink3.mk,v 1.2 2004/01/04 23:34:06 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PERL5_BUILDLINK3_MK:=	${PERL5_BUILDLINK3_MK}+

.if !empty(PERL5_BUILDLINK3_MK:M+)
.  include "../../mk/bsd.prefs.mk"

USE_PERL5?=	run
PERL5_REQD?=	5.0

BUILDLINK_DEPENDS.perl?=	perl>=${PERL5_REQD}
BUILDLINK_PKGSRCDIR.perl?=	../../lang/perl5

.  if !empty(USE_PERL5:M[bB][uU][iI][lL][dD])
BUILDLINK_DEPMETHOD.perl?=	build
.  endif
.endif  # PERL5_BUILDLINK3_MK

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	perl
.endif

.if !empty(PERL5_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=	perl

_PERL5_SITEVARS=							\
	INSTALLSITEBIN INSTALLSITELIB INSTALLSITEARCH			\
	INSTALLSITEMAN1DIR INSTALLSITEMAN3DIR				\
	SITELIBEXP SITEARCHEXP

_PERL5_SITEVAR.INSTALLSITEBIN=		installsitebin
_PERL5_SITEVAR.INSTALLSITELIB=		installsitelib
_PERL5_SITEVAR.INSTALLSITEARCH=		installsitearch
_PERL5_SITEVAR.INSTALLSITEMAN1DIR=	installsiteman1dir
_PERL5_SITEVAR.INSTALLSITEMAN3DIR=	installsiteman3dir
_PERL5_SITEVAR.SITELIBEXP=		sitelibexp
_PERL5_SITEVAR.SITEARCHEXP=		sitearchexp

.if !defined(_PERL5_SITEPREFIX)
.  if exists(${PERL5})
_PERL5_PREFIX!=		\
	eval `${PERL5} -V:prefix 2>/dev/null`; ${ECHO} $$prefix
_PERL5_SITEPREFIX!=	\
	eval `${PERL5} -V:siteprefix 2>/dev/null`; ${ECHO} $$siteprefix
MAKEFLAGS+=	_PERL5_PREFIX="${_PERL5_PREFIX}"
MAKEFLAGS+=	_PERL5_SITEPREFIX="${_PERL5_SITEPREFIX}"

.    for _var_ in ${_PERL5_SITEVARS}
PERL5_SUB_${_var_}!=	\
	eval `${PERL5} -V:${_PERL5_SITEVAR.${_var_}} 2>/dev/null`;	\
	${ECHO} $${${_PERL5_SITEVAR.${_var_}}} |			\
	${SED} -e "s,^${_PERL5_SITEPREFIX}/,,"
MAKEFLAGS+=	PERL5_SUB_${_var_}="${PERL5_SUB_${_var_}}"
.    endfor
PERL5_SUB_INSTALLSCRIPT!=	\
	eval `${PERL5} -V:installscript 2>/dev/null`;			\
	${ECHO} $$installscript |					\
	${SED} -e "s,^${_PERL5_PREFIX}/,,"
MAKEFLAGS+=	PERL5_SUB_INSTALLSCRIPT="${PERL5_SUB_INSTALLSCRIPT}"
.  endif
.endif

.  if ${PKG_INSTALLATION_TYPE} == "overwrite"
#
# Perl keeps headers and odd libraries in an odd path not caught by the
# default BUILDLINK_FILES_CMD, so name them to be symlinked into
# ${BUILDLINK_DIR}.
#
.    if !defined(_PERL5_INSTALLARCHLIB)
_PERL5_INSTALLARCHLIB!=							\
	eval `${PERL5} -V:installarchlib 2>/dev/null`;			\
	${ECHO} $$installarchlib
MAKEFLAGS+=	_PERL5_INSTALLARCHLIB="${_PERL5_INSTALLARCHLIB}"
.    endif
_PERL5_SUB_INSTALLARCHLIB=						\
	${_PERL5_INSTALLARCHLIB:S,^${BUILDLINK_PREFIX.perl}/,,}
BUILDLINK_FILES.perl=							\
        ${_PERL5_SUB_INSTALLARCHLIB}/CORE/*				\
	${_PERL5_SUB_INSTALLARCHLIB}/auto/DynaLoader/DynaLoader.a
.  endif
.endif  # PERL5_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
