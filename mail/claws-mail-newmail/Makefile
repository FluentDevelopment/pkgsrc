# $NetBSD: Makefile,v 1.52 2017/04/30 01:21:48 ryoon Exp $
#

PLUGIN_NAME=    newmail
PKGREVISION= 1
.include "../../mail/claws-mail/plugins.mk"

MAINTAINER=	pkgsrc-users@NetBSD.org
COMMENT=	Write log file info on arriving email

CONFIGURE_ARGS+= --enable-${PLUGIN_NAME}-plugin

DEPENDS+=	claws-mail-${CLAWS_VERSION}{,nb[0-9]*}:../../mail/claws-mail

.include "../../mk/bsd.pkg.mk"
