# $NetBSD: options.mk,v 1.7 2005/05/24 21:02:53 xtraeme Exp $
#

PKG_OPTIONS_VAR=	PKG_OPTIONS.jabberd2
PKG_SUPPORTED_OPTIONS=	db mysql pgsql ldap PAM
PKG_DEFAULT_OPTIONS=	mysql
.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mmysql) && !empty(PKG_OPTIONS:Mpgsql)
PKG_FAIL_REASON+=	"Cannot use mysql and pgsql, use one of them."
.endif

.if !empty(PKG_OPTIONS:Mdb)
BUILD_DEFS+=		JABBERD_DBDIR
JABBERD_DBDIR?=         ${VARBASE}/db/jabberd
CONFIGURE_ARGS+=        --enable-db
.  include "../../databases/db4/buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mmysql)
CONFIGURE_ARGS+=        --enable-mysql
CPPFLAGS+=              -I${BUILDLINK_PREFIX.mysql-client}/include/mysql
.  include "../../mk/mysql.buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mpgsql)
CONFIGURE_ARGS+=        --enable-pgsql
.  include "../../mk/pgsql.buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mldap)
CONFIGURE_ARGS+=        --enable-ldap
.  include "../../databases/openldap/buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:MPAM)
CONFIGURE_ARGS+=        --enable-pam
.  include "../../mk/pam.buildlink3.mk"
.endif
