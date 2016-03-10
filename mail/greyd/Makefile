# $NetBSD$

PKGVERSION=		0.9.2
PKGNAME=		greyd-${PKGVERSION}
DISTNAME=		v${PKGVERSION}
CATEGORIES=		mail
MASTER_SITES=		https://github.com/mikey-austin/greyd/archive/
WRKSRC=			${WRKDIR}/${PKGNAME}
LICENSE=		bsd

MAINTAINER=		timshel@fluentdevelopment.com.au
HOMEPAGE=		http://greyd.org/
COMMENT=		OpenBSD spam deferral daemon

GREYD_HOME=		${VARBASE}/chroot/spamd
OWN_DIRS=		${GREYD_HOME}

CPPFLAGS+=		-DPATH_GREYD_HOME=\"${GREYD_HOME}\"
CPPFLAGS+=		-DPATH_GREYD_DB=\"${VARBASE}/db/spamd\"
CPPFLAGS+=		-DPATH_PFCTL=\"${PFCTL}\"
CPPFLAGS+=		-DPATH_GREYD_CONF=\"${GREYD_CONF}\"

PKG_GROUPS=		_greyd
PKG_USERS=		_greyd:_greyd
PKG_GECOS._greyd=	Greylisting Daemon User
PKG_HOME._greyd=	${GREYD_HOME}

RCD_SCRIPTS=		greyd

.include "options.mk"

GNU_CONFIGURE=          yes
CONFIGURE_ARGS+=        --sysconfdir=${PKG_SYSCONFDIR}
#HAS_CONFIGURE=		yes

#AUTOCONF_REQD=  	2.50           # if default version is not good enough
USE_TOOLS+= 		autoconf        # use "autoconf213" for autoconf-2.13
USE_TOOLS+= 		automake
USE_LIBTOOL=		yes
USE_TOOLS+=		gmake
MAKE_PROGRAM=		gmake

GREYD_CONF=		${PKG_SYSCONFDIR}/greyd.conf
CONF_FILES=		${PREFIX}/share/examples/greyd/greyd.conf ${GREYD_CONF}

SUBST_CLASSES+=		fix
SUBST_STAGE.fix=	post-patch
SUBST_FILES.fix=	doc/greyd.8
SUBST_FILES.fix+=	doc/greyd.conf.5
SUBST_FILES.fix+=	doc/greyd-setup.8
SUBST_SED.fix=		-e 's,/etc/greyd,${PKG_SYSCONFDIR}/greyd,g'
SUBST_SED.fix+=		-e 's,/usr/sbin/,${PREFIX}/sbin/,g'
SUBST_MESSAGE.fix=	Fixing configuration paths.

INSTALLATION_DIRS+=	libexec sbin ${PKGMANDIR}/cat5 ${PKGMANDIR}/man5
INSTALLATION_DIRS+=	${PKGMANDIR}/cat8 ${PKGMANDIR}/man8 share/examples/greyd

pre-configure:
	set -e; cd ${WRKSRC}; \
	aclocal; autoheader; libtoolize; automake -a --foreign -i; autoconf

do-install:
	# ${INSTALL_MAN} ${WRKSRC}/doc/greyd.conf.5 \
	# 	${DESTDIR}${PREFIX}/${PKGMANDIR}/man5
	# ${INSTALL_MAN} ${WRKSRC}/doc/greyd.8 \
	# 	${DESTDIR}${PREFIX}/${PKGMANDIR}/man8
	# ${INSTALL_MAN} ${WRKSRC}/doc/greyd-setup.8 \
	# 	${DESTDIR}${PREFIX}/${PKGMANDIR}/man8
	# ${INSTALL_MAN} ${WRKSRC}/doc/greydb.8 \
	# 	${DESTDIR}${PREFIX}/${PKGMANDIR}/man8
	# ${INSTALL_MAN} ${WRKSRC}/doc/greylogd.8 \
	# 	${DESTDIR}${PREFIX}/${PKGMANDIR}/man8

	set -e; cd ${WRKSRC}/doc; ${MAKE_PROGRAM} install DESTDIR=${DESTDIR}
	set -e; cd ${WRKSRC}/drivers; ${MAKE_PROGRAM} install DESTDIR=${DESTDIR}
	${INSTALL_PROGRAM} ${WRKSRC}/src/greyd-setup \
		${DESTDIR}${PREFIX}/libexec
	${INSTALL_PROGRAM} ${WRKSRC}/src/greyd \
		${DESTDIR}${PREFIX}/libexec
	${INSTALL_PROGRAM} ${WRKSRC}/src/greydb \
		${DESTDIR}${PREFIX}/sbin
	${INSTALL_PROGRAM} ${WRKSRC}/src/greylogd \
		${DESTDIR}${PREFIX}/libexec
	${INSTALL_DATA} ${WRKSRC}/etc/greyd.conf \
		${DESTDIR}${PREFIX}/share/examples/greyd

.include "../../devel/libltdl/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
