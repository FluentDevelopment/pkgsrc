# $NetBSD: catalogs.mk,v 1.1 2003/01/29 20:21:07 jmmv Exp $
#
# This Makefile fragment is intended to be included by packages that install
# catalog files or DTDs.  It takes care of registering them into the right
# database.
#
# The following variables are automatically defined for free use in packages:
#    XMLCATMGR            - Path to the xmlcatmgr program.
#    SGML_DEFAULT_CATALOG - Path to the system-wide (tunable) SGML catalog.
#    XML_DEFAULT_CATALOG  - Path to the system-wide (tunable) XML catalog.
#
# Packages that recognize a system-wide catalog file should be configured
# to use SGML_DEFAULT_CATALOG or XML_DEFAULT_CATALOG, depending on the
# type of tool they are.
#
# The following variables can be defined by a package to automatically
# register catalog files:
#    SGML_CATALOGS - List of SGML catalogs to register into share/sgml/catalog.
#    XML_CATALOGS  - List of XML catalogs to register into share/xml/catalog.
#
# If you need to call xmlcatmgr with very specific arguments, you can use
# the following variables.  Add three words each time; they are fed to
# xmlcatmgr in groups of three when calling the `add' action.
#    SGML_ENTRIES - Extra arguments used to add entries to the SGML catalog.
#    XML_ENTRIES  - Extra arguments used to add entries to the XML catalog.
#

.if !defined(XMLCATMGR_CATALOGS_MK)
XMLCATMGR_CATALOGS_MK=	# defined

# Location of the xmlcatmgr binary program.
XMLCATMGR=	${BUILDLINK_PREFIX.xmlcatmgr}/bin/xmlcatmgr

# System-wide configurable catalogs.
.if defined(PKG_SYSCONFDIR.xmlcatmgr) && !empty(PKG_SYSCONFDIR.xmlcatmgr)
SGML_DEFAULT_CATALOG=	${PKG_SYSCONFDIR.xmlcatmgr}/sgml/catalog
XML_DEFAULT_CATALOG=	${PKG_SYSCONFDIR.xmlcatmgr}/xml/catalog
.else
SGML_DEFAULT_CATALOG=	${PKG_SYSCONFBASE}/sgml/catalog
XML_DEFAULT_CATALOG=	${PKG_SYSCONFBASE}/xml/catalog
.endif

# Catalogs to be registered.
SGML_CATALOGS?=
XML_CATALOGS?=

# Single entries to be added to catalogs.
SGML_ENTRIES?=
XML_ENTRIES?=

# Convert SGML_CATALOGS files into arguments for SGML_ENTRIES.
.if !empty(SGML_CATALOGS)
.for c in ${SGML_CATALOGS}
SGML_ENTRIES+=	CATALOG ${PREFIX:=$c} --
.endfor
.endif

# Convert XML_CATALOGS files into arguments for XML_ENTRIES.
.if !empty(XML_CATALOGS)
.for c in ${XML_CATALOGS}
XML_ENTRIES+=	nextCatalog ${PREFIX:=$c} --
.endfor
.endif

# If there are any entries to register, export required variables and
# use bsd.pkg.install.mk.
.if !empty(SGML_ENTRIES) || !empty(XML_ENTRIES)
FILES_SUBST+=	XMLCATMGR="${XMLCATMGR}"
FILES_SUBST+=	SGML_CATALOG="${BUILDLINK_PREFIX.xmlcatmgr}/share/sgml/catalog"
FILES_SUBST+=	XML_CATALOG="${BUILDLINK_PREFIX.xmlcatmgr}/share/xml/catalog"
FILES_SUBST+=	SGML_ENTRIES="${SGML_ENTRIES}"
FILES_SUBST+=	XML_ENTRIES="${XML_ENTRIES}"
INSTALL_EXTRA_TMPL+=	../../textproc/xmlcatmgr/files/install.tmpl
DEINSTALL_EXTRA_TMPL+=	../../textproc/xmlcatmgr/files/deinstall.tmpl
USE_PKGINSTALL=	YES
.endif # !empty(SGML_ENTRIES) || !empty(XML_ENTRIES)

USE_BUILDLINK2=	YES
.include "../../textproc/xmlcatmgr/buildlink2.mk"

.endif	# XMLCATMGR_CATALOGS_MK
