# $NetBSD: hacks.mk,v 1.4 2004/12/10 23:12:47 jlam Exp $

.include "../../mk/compiler.mk"

### [Thu Jun 7 04:25:34 UTC 2001 : jlam]
### Fix brokenness when using an older toolchain (gcc<3.3) on
### NetBSD/sparc64.  Pass -g and -DDEBUGGING to the compiler to
### circumvent some code-generation bugs.
###
.if !empty(MACHINE_PLATFORM:MNetBSD-*-sparc64)
.  if !empty(CC_VERSION:Mgcc*)
.    if !defined(_GCC_IS_TOO_OLD)
_GCC_IS_TOO_OLD!=	\
	if ${PKG_ADMIN} pmatch 'gcc<3.3' ${CC_VERSION}; then		\
		${ECHO} "yes";						\
	else								\
		${ECHO} "no";						\
	fi
MAKEFLAGS+=	_GCC_IS_TOO_OLD=${_GCC_IS_TOO_OLD}
.    endif
.    if !empty(_GCC_IS_TOO_OLD:M[yY][eE][sS])
PKG_HACKS+=	sparc64-codegen
CFLAGS+=	-DDEBUGGING -g -msoft-quad-float -O2
.    endif
.  endif
.endif

### [Sun Nov 14 02:35:50 EST 2004 : jlam]
### On PowerPC, building with optimisation with GCC causes an "attempt
### to free unreference scalar".  Remove optimisation flags as a
### workaround until GCC is fixed.
###
.if !empty(CC_VERSION:Mgcc*) && !empty(MACHINE_PLATFORM:MNetBSD-*-powerpc)
PKG_HACKS+=		powerpc-codegen
BUILDLINK_TRANSFORM+=	rm:-O[0-9]*
.endif

### [Fri Dec 10 18:09:51 EST 2004 : jlam]
### On VAX, feeding a base "NaN" to nawk causes nawk to core dump since
### it tries to interpret it as a number, which causes an FP exception.
### Modify files that pass through nawk to not have bare "NaN"s.
###
.if !empty(MACHINE_PLATFORM:M*-*-vax)
PKG_HACKS+=		NaN-vax-exception
.PHONY: NaN-vax-exception
pre-configure: NaN-vax-exception
NaN-vax-exception:
	cd ${WRKSRC}; for file in MANIFEST; do				\
		${MV} $$file $$file.NaN;				\
		${SED} -e "s,NaN,*NaN*,g" $$file.NaN > $$file;		\
	done
.endif
