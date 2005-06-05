# $NetBSD: options.mk,v 1.8 2005/06/05 14:17:53 taca Exp $

# Global and legacy options

PKG_OPTIONS_VAR=	PKG_OPTIONS.samba
PKG_SUPPORTED_OPTIONS=	pam ads cups ldap ldap-compat
.include "../../mk/bsd.options.mk"

###
### Support PAM authentication and build smbpass and winbind PAM modules.
###
.if !empty(PKG_OPTIONS:Mpam)
.  include "../../security/PAM/module.mk"
CONFIGURE_ARGS+=	--with-pam
CONFIGURE_ARGS+=	--with-pam_smbpass
PLIST_SUBST+=		PAM=
.else
PLIST_SUBST+=		PAM="@comment "
.endif

###
### Allow Samba to join as a member server of an Active Directory domain.
###
.if !empty(PKG_OPTIONS:Mads)
.  include "../../mk/krb5.buildlink3.mk"
PKG_OPTIONS+=		ldap
CONFIGURE_ARGS+=	--with-ads
CONFIGURE_ARGS+=	--with-krb5=${KRB5BASE}
.else
CONFIGURE_ARGS+=	--without-ads
CONFIGURE_ARGS+=	--without-krb5
.endif

###
### Native CUPS support for printing
###
.if !empty(PKG_OPTIONS:Mcups)
.  include "../../print/cups/buildlink3.mk"
CONFIGURE_ARGS+=	--enable-cups
PLIST_SUBST+=		CUPS=
.else
CONFIGURE_ARGS+=	--disable-cups
PLIST_SUBST+=		CUPS="@comment "
.endif

###
### Support Samba-2.x LDAP password and account databases.
###
.if !empty(PKG_OPTIONS:Mldap-compat)
PKG_OPTIONS+=		ldap
CONFIGURE_ARGS+=	--with-ldapsam
.endif

###
### Support LDAP authentication and storage of Samba account information.
###
.if !empty(PKG_OPTIONS:Mldap)
.  include "../../databases/openldap/buildlink3.mk"
CONFIGURE_ARGS+=	--with-ldap
.else
CONFIGURE_ARGS+=	--without-ldap
.endif

###
### Only Linux supports smbmount for mounting a Samba share into the
### filesystem.
###
.if ${OPSYS} == "Linux"
CONFIGURE_ARGS+=	--with-smbmount
PLIST_SUBST+=		SMBMOUNT=
.else
PLIST_SUBST+=		SMBMOUNT="@comment "
.endif

###
### Determine the proper name for the winbind and WINS NSS modules.
###
NSS_WINBIND.${OPSYS}?=  libnss_winbind.so
NSS_WINS.${OPSYS}?=     libnss_wins.so

NSS_WINBIND.AIX=        WINBIND
NSS_WINS.AIX=           # empty

NSS_WINBIND.DragonFly=	# empty
NSS_WINS.DragonFly=	# empty

NSS_WINBIND.IRIX=       libns_winbind.so
NSS_WINS.IRIX=          libns_wins.so

.if !empty(MACHINE_PLATFORM:MFreeBSD-5.*)
NSS_WINBIND.FreeBSD=    nss_winbind.so
NSS_WINS.FreeBSD=       nss_wins.so
.endif

NSS_WINBIND=            ${NSS_WINBIND.${OPSYS}}
NSS_WINS=               ${NSS_WINS.${OPSYS}}
