# $NetBSD$

DISTNAME=		greyd-0.9.2
CATEGORIES=		mail
MASTER_SITES=		${MASTER_SITE_GITHUB:=mikey-austin/}
GITHUB_TAG=		v${PKGVERSION_NOREV}

MAINTAINER=		timshel@fluentdevelopment.com.au
HOMEPAGE=		http://greyd.org/
LICENSE=		isc
COMMENT=		Portable, firewall-integrated SMTP spam deferral & greylisting daemon

PKG_GROUPS=		greyd
PKG_USERS=		greyd:greyd
PKG_GECOS.greyd=	Greylisting Daemon User
PKG_HOME.greyd=		${GREYD_HOME}

RCD_SCRIPTS=		greyd

.include "options.mk"

GNU_CONFIGURE=          yes
CONFIGURE_ARGS+=        --sysconfdir=${PKG_SYSCONFDIR}
CONFIGURE_ARGS+=        --localstatedir=${VARBASE}

CONFIGURE_ENV+= 	GREYD_PIDFILE=${GREYD_HOME}/greyd.pid
CONFIGURE_ENV+= 	GREYLOGD_PIDFILE=${GREYD_HOME}/greylogd.pid

USE_TOOLS+= 		aclocal
USE_TOOLS+= 		autoheader
USE_TOOLS+= 		autoconf
USE_TOOLS+= 		automake
USE_LIBTOOL=		yes
USE_TOOLS+=		gmake
MAKE_PROGRAM=		gmake

CPPFLAGS+=             -DGREYD_CHROOT_DIR=\"${GREYD_HOME}\"

BUILD_DEFS+=		VARBASE

GREYD_HOME=		${VARBASE}/chroot/greyd

GREYD_CONFDIR=		${PKG_SYSCONFDIR}/greyd
GREYD_CONF=		${GREYD_CONFDIR}/greyd.conf
CONF_FILES=		${PREFIX}/share/examples/greyd/greyd.conf ${GREYD_CONF}

OWN_DIRS=		${GREYD_HOME}
OWN_DIRS+=		${GREYD_CONFDIR}

# We use @GREYD_CONF@ in the rc.d script
FILES_SUBST+=		GREYD_CONF=${GREYD_CONF:Q}

SUBST_CLASSES+=		fix-paths
SUBST_STAGE.fix-paths=	post-patch
SUBST_FILES.fix-paths=	doc/greyd.8
SUBST_FILES.fix-paths+=	etc/greyd.conf.in
SUBST_SED.fix-paths=	-e 's,/etc/greyd,${GREYD_CONFDIR},g'
# greydb lives in sbin/; substitute this first...
SUBST_SED.fix-paths+=	-e 's,/usr/\(sbin/greydb\),${PREFIX}/\1/,g'
# and then make sure references to other executables point to libexec/
SUBST_SED.fix-paths+=	-e 's,/usr/sbin/\(greyd\),${PREFIX}/libexec/\1/,g'
SUBST_SED.fix-paths+=	-e 's,/var/empty/greyd,${GREYD_HOME},g'
SUBST_MESSAGE.fix-paths=	Fixing pkgsrc paths.

GREYD_MANS=		greyd.conf.5 greyd.8 greyd-setup.8 greydb.8 greylogd.8

INSTALLATION_DIRS+=	libexec sbin ${PKGMANDIR}/cat5 ${PKGMANDIR}/man5
INSTALLATION_DIRS+=	${PKGMANDIR}/cat8 ${PKGMANDIR}/man8 share/examples/greyd

pre-configure:
	set -e; cd ${WRKSRC}; \
	aclocal; autoheader; libtoolize; automake -a --foreign -i; autoconf

do-install:
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
.for man in ${GREYD_MANS}; do \
	${INSTALL_MAN} ${WRKSRC}/doc/${man} ${DESTDIR}${PREFIX}/${PKGMANDIR}/man${man:C/.*\.//W}
.endfor

.include "../../devel/libltdl/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
