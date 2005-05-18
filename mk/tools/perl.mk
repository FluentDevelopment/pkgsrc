# $NetBSD: perl.mk,v 1.12 2005/05/18 22:42:07 jlam Exp $

# Create a symlink from ${TOOLS_DIR}/bin/perl to ${PERL5} when USE_PERL5
# is defined.  This ensures that when "perl" is invoked, the pkgsrc perl
# is executed on systems that also provide a perl binary.
#
.if defined(USE_PERL5)
USE_TOOLS+=		perl
.  if empty(USE_PERL5:Mbuild)
TOOLS_DEPMETHOD.perl?=	DEPENDS
.  endif
.endif

# Skip the processing at the end of replace.mk.  If we need to use
# perl, then we always want the clause below to trigger.
#
_TOOLS_USE_PKGSRC.perl=	yes

.if !defined(TOOLS_IGNORE.perl) && !empty(USE_TOOLS:Mperl)
.  if !empty(PKGPATH:Mlang/perl58)
MAKEFLAGS+=			TOOLS_IGNORE.perl=
.  else
.    include "../../lang/perl5/version.mk"
TOOLS_DEPMETHOD.perl?=		BUILD_DEPENDS
TOOLS_DEPENDS.perl?=		{perl>=${PERL5_REQD},perl-thread>=${PERL5_REQD}}:../../lang/perl58
TOOLS_CREATE+=			perl
FIND_PREFIX:=			TOOLS_PREFIX.perl=perl
.    include "../../mk/find-prefix.mk"
TOOLS_REAL_CMD.perl=		${TOOLS_PREFIX.perl}/bin/perl
TOOLS_${_TOOLS_VARNAME.perl}=	${TOOLS_REAL_CMD.perl}
${_TOOLS_VARNAME.perl}?=	${TOOLS_${_TOOLS_VARNAME.perl}}
CONFIGURE_ENV+=			PERL=${TOOLS_${_TOOLS_VARNAME.perl}:Q}
.  endif

# Define PERL5_* variables that locate the site directories for ${PERL5}.
# These variables depend on PERL5 being properly defined and existing
# on the filesystem.
#
.  include "../../lang/perl5/vars.mk"

.endif
