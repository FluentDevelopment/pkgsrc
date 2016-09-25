# $NetBSD$

PKG_OPTIONS_VAR=		PKG_OPTIONS.greyd
PKG_SUPPORTED_OPTIONS=		bdb mysql netfilter npf pf spf sqlite
# Where is the bdb-sql library in pkgsrc?
#PKG_SUPPORTED_OPTIONS+=	bdb-sql
# TODO: package tries to build bdb support by default if none of bdb, mysql or sqlite are selected
#       create configure.ac patch to fix this?
#
# Default options
#
PKG_SUGGESTED_OPTIONS=		bdb spf

.include "../../mk/bsd.prefs.mk"

.if !empty(MACHINE_PLATFORM:MNetBSD-[6-9].*-*)
PKG_SUGGESTED_OPTIONS+=		npf
.endif

.if !empty(MACHINE_PLATFORM:MNetBSD-[6-9].*-*) || \
    !empty(MACHINE_PLATFORM:MOpenBSD-*-*) || \
    !empty(MACHINE_PLATFORM:MFreeBSD-5.[3-5].*-*) || \
    !empty(MACHINE_PLATFORM:MFreeBSD-[6-9].*-*) || \
    !empty(MACHINE_PLATFORM:MFreeBSD-1[0-9].*-*) || \
    !empty(MACHINE_PLATFORM:MDragonflyBSD-[6-9].*-*)
PKG_SUGGESTED_OPTIONS+=		pf
.endif

.if !empty(MACHINE_PLATFORM:MLinux-*)
PKG_SUGGESTED_OPTIONS+=		netfilter
.endif

.include "../../mk/bsd.options.mk"

###
### BDB support
###
PLIST_VARS+=		bdb
.if !empty(PKG_OPTIONS:Mbdb)
PLIST.bdb=		yes
BDB_ACCEPTED=		db4 db5
BUILDLINK_TRANSFORM+=	l:db:${BDB_TYPE}
. include "../../mk/bdb.buildlink3.mk"
CONFIGURE_ARGS+=	--with-bdb
# CONFIGURE_ARGS+=	--with-bdb-sql
# BDB_INCLUDE_DIR_ and BDB_LIB_DIR don't have to be particularly accurate
# since the real -I and -L flags are added by buildlink already.
CONFIGURE_ENV+=	 	BDB_INCLUDE_DIR=${BDBBASE}/include
CONFIGURE_ENV+=	 	BDB_LIB_DIR=${BDBBASE}/lib
CONFIGURE_ENV+=	 	BDB_LIB=${BDB_LIBS:S/^-l//:M*:Q}

# TODO: The DB dir... how does this work in relation to the chroot?
GREYD_DBDIR+=		${VARBASE}/db/greyd
OWN_DIRS+=		${GREYD_DBDIR}
# TODO: Do we need to install this folder? How do we set appropriate perms on it?
INSTALLATION_DIRS+=	${GREYD_DBDIR}

.endif

###
### MySQL support
###
PLIST_VARS+=		mysql
.if !empty(PKG_OPTIONS:Mmysql)
PLIST.mysql=		yes
CONFIGURE_ARGS+=	--with-mysql
. include "../../mk/mysql.buildlink3.mk"
.endif

###
### Linux Netfilter support
###
PLIST_VARS+=		netfilter
.if !empty(PKG_OPTIONS:Mnetfilter)
PLIST.netfilter=	yes
CONFIGURE_ARGS+=	--with-netfilter
. if empty(MACHINE_PLATFORM:MLinux-*-*)
PKG_FAIL_REASON=	"netfilter not available on this system"
. endif
.endif

###
### NPF
###
PLIST_VARS+=		npf
.if !empty(PKG_OPTIONS:Mnpf)
PLIST.npf=		yes
CONFIGURE_ARGS+=	--with-npf
.	if empty(MACHINE_PLATFORM:MNetBSD-[6-9].*-*)
PKG_FAIL_REASON=	"npf not available on this system"
.	endif
.endif

###
### Include pf support (OpenBSD packet filter) on supported systems
###
PLIST_VARS+=		pf
.if !empty(PKG_OPTIONS:Mpf)
PLIST.pf=		yes
CONFIGURE_ARGS+=	--with-pf
. include "../../mk/pf.buildlink3.mk"
. if empty(MACHINE_PLATFORM:MNetBSD-[6-9].*-*) && \
     empty(MACHINE_PLATFORM:MOpenBSD-*-*) && \
     empty(MACHINE_PLATFORM:MFreeBSD-5.[3-5].*-*) && \
     empty(MACHINE_PLATFORM:MFreeBSD-[6-9].*-*) && \
     empty(MACHINE_PLATFORM:MFreeBSD-1[0-9].*-*) && \
     empty(MACHINE_PLATFORM:MDragonflyBSD-[6-9].*-*)
PKG_FAIL_REASON=	"pf not available on this system"
. endif
.endif

###
### Include SPF support using libspf2
###
.if !empty(PKG_OPTIONS:Mspf)
CONFIGURE_ARGS+=	--with-spf
. include "../../mail/libspf2/buildlink3.mk"
.endif


###
### SQLite support
###
PLIST_VARS+=		sqlite
.if !empty(PKG_OPTIONS:Msqlite)
PLIST.sqlite=		yes
CONFIGURE_ARGS+=	--with-sqlite
. include "../../databases/sqlite/buildlink3.mk"
.endif
