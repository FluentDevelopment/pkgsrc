# $NetBSD: buildlink3.mk,v 1.1 2004/02/01 10:11:39 jlam Exp $
#
# This Makefile fragment is included by packages that use xmlcatmgr.
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

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
XMLCATMGR_BUILDLINK3_MK:=	${XMLCATMGR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xmlcatmgr
.endif

.if !empty(XMLCATMGR_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=			xmlcatmgr
BUILDLINK_DEPENDS.xmlcatmgr+=		xmlcatmgr>=0.2
BUILDLINK_RECOMMENDED.xmlcatmgr+=	xmlcatmgr>=2.0beta1
BUILDLINK_PKGSRCDIR.xmlcatmgr?=		../../textproc/xmlcatmgr

# Location of the xmlcatmgr binary program.
XMLCATMGR=	${BUILDLINK_PREFIX.xmlcatmgr}/bin/xmlcatmgr

# System-wide configurable catalogs.
.  if defined(PKG_SYSCONFDIR.xmlcatmgr) && !empty(PKG_SYSCONFDIR.xmlcatmgr)
SGML_DEFAULT_CATALOG=	${PKG_SYSCONFDIR.xmlcatmgr}/sgml/catalog
XML_DEFAULT_CATALOG=	${PKG_SYSCONFDIR.xmlcatmgr}/xml/catalog
.  else
SGML_DEFAULT_CATALOG=	${PKG_SYSCONFBASEDIR}/sgml/catalog
XML_DEFAULT_CATALOG=	${PKG_SYSCONFBASEDIR}/xml/catalog
.  endif
.endif # XMLCATMGR_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
