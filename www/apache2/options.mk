# $NetBSD: options.mk,v 1.2 2004/12/22 21:46:25 jlam Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.apache
PKG_SUPPORTED_OPTIONS=	suexec

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Msuexec)
APACHE_SUEXEC_DOCROOT?=	${PREFIX}/share/httpd/htdocs
APACHE_SUEXEC_PATH=	/bin:/usr/bin:${PREFIX}/bin:/usr/local/bin
APACHE_SUEXEC_CONFIGURE_ARGS+=						\
	--with-suexec-bin=${PREFIX}/sbin/suexec				\
	--with-suexec-caller=${APACHE_USER}				\
	--with-suexec-safepath='${APACHE_SUEXEC_PATH}'			\
	--with-suexec-docroot=${APACHE_SUEXEC_DOCROOT}			\
	--with-suexec-logfile=${VARBASE}/log/httpd/suexec.log

APACHE_MODULES+=        suexec
CONFIGURE_ARGS+=        ${APACHE_SUEXEC_CONFIGURE_ARGS:M--with-suexec-*}
BUILD_DEFS+=            APACHE_SUEXEC_CONFIGURE_ARGS
PLIST_SUBST+=           SUEXEC_COMMENT=
.else
PLIST_SUBST+=           SUEXEC_COMMENT="@comment "
.endif
