# $NetBSD: hacks.mk,v 1.2 2006/01/12 20:32:04 adam Exp $

.include "../../mk/bsd.prefs.mk"

.if ${OPSYS} == "DragonFly" && ${PKGSRC_COMPILER} == "gcc"
#
# Workaround an ICE in the stack-smashing protection in GCC 3.4.x.
#
.if !defined(HAS_PROPOLICE)
HAS_PROPOLICE!=	( ${CC} -v 2>&1 | ${GREP} 'propolice' ) 2>/dev/null || echo no
MAKEVARS+=	HAS_PROPOLICE
.endif

.if ${HAS_PROPOLICE} != "no"
CFLAGS+=	-fno-stack-protector
CXXFLAGS+=	-fno-stack-protector
.endif
.endif
