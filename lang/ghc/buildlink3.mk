# $NetBSD: buildlink3.mk,v 1.5 2006/04/12 10:27:21 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GHC_BUILDLINK3_MK:=	${GHC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	ghc
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nghc}
BUILDLINK_PACKAGES+=	ghc

.if !empty(GHC_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.ghc+=		ghc>=6.2.1nb1
BUILDLINK_ABI_DEPENDS.ghc?=	ghc>=6.4.1nb1
BUILDLINK_PKGSRCDIR.ghc?=	../../lang/ghc

BUILDLINK_DEPMETHOD.ghc?=	build
.endif	# GHC_BUILDLINK3_MK

.include "../../devel/readline/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}

# We include gmp/buildlink3.mk here so that "gmp" is registered as a
# direct dependency for any package that includes this buildlink3.mk
# to get ghc as a build dependency.  This is needed since software
# built by ghc requires routines from the "gmp" shared library.
#
.include "../../devel/gmp/buildlink3.mk"
