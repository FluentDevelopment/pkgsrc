# $NetBSD: Makefile,v 1.23 2017/02/01 13:31:52 mef Exp $
#

DISTNAME=	HTML-Scrubber-0.15
PKGNAME=	p5-${DISTNAME}
PKGREVISION=	1
#PKGREVISION=	0
CATEGORIES=	www perl5
MASTER_SITES=	${MASTER_SITE_PERL_CPAN:=HTML/}

MAINTAINER=	pkgsrc-users@NetBSD.org
COMMENT=	Extension for scrubbing/sanitizing html
LICENSE=	${PERL5_LICENSE}

DEPENDS+=	p5-HTML-Parser>=3.47:../../www/p5-HTML-Parser
BUILD_DEPENDS+=	p5-Test-NoTabs-[0-9]*:../../devel/p5-Test-NoTabs

# for make test
BUILD_DEPENDS+=	p5-Test-CPAN-Meta-[0-9]*:../../devel/p5-Test-CPAN-Meta
BUILD_DEPENDS+=	p5-Test-EOL-[0-9]*:../../devel/p5-Test-EOL
BUILD_DEPENDS+=	p5-Test-Memory-Cycle-[0-9]*:../../devel/p5-Test-Memory-Cycle

PERL5_MODULE_TYPE=	Module::Build

USE_LANGUAGES=		# empty
PERL5_PACKLIST=		auto/HTML/Scrubber/.packlist

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
