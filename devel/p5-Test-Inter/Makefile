# $NetBSD: Makefile,v 1.13 2016/06/08 19:23:38 wiz Exp $
#

DISTNAME=	Test-Inter-1.06
PKGNAME=	p5-${DISTNAME}
PKGREVISION=	2
CATEGORIES=	devel perl5
MASTER_SITES=	${MASTER_SITE_PERL_CPAN:=Test/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://search.cpan.org/dist/Test-Inter/
COMMENT=	Perl 5 framework for more readable interactive tests
LICENSE=	${PERL5_LICENSE}

USE_LANGUAGES=	# empty
PERL5_MODULE_TYPE=	Module::Build
PERL5_PACKLIST=	auto/Test/Inter/.packlist

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
