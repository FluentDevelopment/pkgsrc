# $NetBSD: bsd.prefs.mk,v 1.50 2001/07/09 14:31:58 fredb Exp $
#
# Make file, included to get the site preferences, if any.  Should
# only be included by package Makefiles before any .if defined()
# statements or modifications to "passed" variables (CFLAGS, LDFLAGS, ...),
# to make sure any variables defined in /etc/mk.conf, $MAKECONF, or
# the system defaults (sys.mk and bsd.own.mk) are used.

# Do not recursively include mk.conf, redefine OPSYS, include bsd.own.mk, etc.
.ifndef BSD_PKG_MK

# Let mk.conf know that this is pkgsrc.
BSD_PKG_MK=1 
__PREFIX_SET__:=${PREFIX}

.if exists(/usr/bin/uname)
UNAME=/usr/bin/uname
.elif exists(/bin/uname)
UNAME=/bin/uname
.else
UNAME=echo Unknown
.endif

.ifndef OPSYS
OPSYS!=			${UNAME} -s
.endif
MAKEFLAGS+=		OPSYS=${OPSYS}
.ifndef OS_VERSION
OS_VERSION!=		${UNAME} -r
.endif
MAKEFLAGS+=		OS_VERSION=${OS_VERSION}

# Preload these for architectures not in all variations of bsd.own.mk.
GNU_ARCH.alpha?=	alpha
GNU_ARCH.arm32?=	arm
GNU_ARCH.i386?=		i386
GNU_ARCH.i486?=		i386
GNU_ARCH.i586?=		i386
GNU_ARCH.i686?=		i386
GNU_ARCH.m68k?=		m68k
GNU_ARCH.mips?=		mipsel
GNU_ARCH.mipseb?=	mipseb
GNU_ARCH.mipsel?=	mipsel
GNU_ARCH.ns32k?=	ns32k
GNU_ARCH.powerpc?=	powerpc
GNU_ARCH.sparc?=	sparc
GNU_ARCH.vax?=		vax
MACHINE_GNU_ARCH?=	${GNU_ARCH.${MACHINE_ARCH}}

.if ${OPSYS} == "NetBSD"
LOWER_OPSYS?=		netbsd
.elif ${OPSYS} == "SunOS"
. if ${MACHINE_ARCH} == "unknown"
.  if !defined(LOWER_ARCH)
LOWER_ARCH!=		${UNAME} -p
.  endif	# !defined(LOWER_ARCH)
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH}
. endif
LOWER_VENDOR?=		sun
LOWER_OPSYS?=		solaris

# We need to set this early to get "USE_MESA" and "USE_XPM" working.
X11BASE?=               ${DESTDIR}/usr/openwin
.elif ${OPSYS} == "Linux"
LOWER_OPSYS?=		linux
. if ${MACHINE_ARCH} == "unknown"
.  if !defined(LOWER_ARCH)
LOWER_ARCH!=		${UNAME} -m | sed -e 's/[456]86/386/'
.  endif # !defined(LOWER_ARCH)
MACHINE_ARCH=		${LOWER_ARCH}
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH}
.  if ${LOWER_ARCH} == "i386"
LOWER_VENDOR?=		pc
.  else
LOWER_VENDOR?=		unknown
.  endif
. endif

.elif !defined(LOWER_OPSYS)
LOWER_OPSYS!=		echo ${OPSYS} | tr A-Z a-z
.endif
MAKEFLAGS+=		LOWER_OPSYS=${LOWER_OPSYS}

LOWER_VENDOR?=
LOWER_ARCH?=		${MACHINE_GNU_ARCH}

MACHINE_PLATFORM?=	${OPSYS}-${OS_VERSION}-${MACHINE_ARCH}
MACHINE_GNU_PLATFORM?=	${LOWER_ARCH}-${LOWER_VENDOR}-${LOWER_OPSYS}

# Needed on NetBSD and SunOS (zoularis) to prevent an "install:" target
# from being created in bsd.own.mk.
NEED_OWN_INSTALL_TARGET=no

.include <bsd.own.mk>

# /usr/share/mk/bsd.own.mk on NetBSD 1.3 does not define OBJECT_FMT
.if ${MACHINE_PLATFORM:MNetBSD-1.3*} != ""
.if ${MACHINE_ARCH} == "alpha" || \
${MACHINE_ARCH} == "mipsel" || ${MACHINE_ARCH} == "mipseb" || \
${MACHINE_ARCH} == "powerpc" || ${MACHINE_ARCH} == "sparc64"
OBJECT_FMT?=ELF
.else
OBJECT_FMT?=a.out
.endif
.endif

.if (${OPSYS} == "NetBSD") || (${OPSYS} == "SunOS") || (${OPSYS} == "Linux")
SHAREOWN?=		${DOCOWN}
SHAREGRP?=		${DOCGRP}
SHAREMODE?=		${DOCMODE}
.endif

.if defined(PREFIX) && (${PREFIX} != ${__PREFIX_SET__})
.BEGIN:
	@${ECHO_MSG} "You can NOT set PREFIX manually or in mk.conf.  Set LOCALBASE or X11BASE"
	@${ECHO_MSG} "depending on your needs.  See the pkg system documentation for more info."
	@${FALSE}
.endif

# if the system is IPv6-ready NetBSD, compile with IPv6 support turned on.
.if (${OPSYS} == "NetBSD") && !defined(USE_SOCKS) && \
    exists(/usr/include/netinet6)
USE_INET6?=		YES
.else
USE_INET6?=		NO
.endif

# Preload all default values for CFLAGS, LDFLAGS, etc. before bsd.pkg.mk
# or a pkg Makefile modifies them.
.include <sys.mk>

# Load the OS-specific definitions for program variables.  Default to loading
# the NetBSD ones if an OS-specific file doesn't exist.
.if exists(${.CURDIR}/../../mk/defs.${OPSYS}.mk)
.include "${.CURDIR}/../../mk/defs.${OPSYS}.mk"
.elif exists(${.CURDIR}/../mk/defs.${OPSYS}.mk)
.include "${.CURDIR}/../mk/defs.${OPSYS}.mk"
.elif exists(${.CURDIR}/mk/defs.${OPSYS}.mk)
.include "${.CURDIR}/mk/defs.${OPSYS}.mk"
.elif exists(${.CURDIR}/../../mk/defs.NetBSD.mk)
.include "${.CURDIR}/../../mk/defs.NetBSD.mk"
.elif exists(${.CURDIR}/../mk/defs.NetBSD.mk)
.include "${.CURDIR}/../mk/defs.NetBSD.mk"
.else exists(${.CURDIR}/mk/defs.NetBSD.mk)
.include "${.CURDIR}/mk/defs.NetBSD.mk"
.endif

# Set default type of libXaw used during package builds.
.if defined(USE_XAW)
XAW_TYPE?=		standard
.endif

# Check if we got Mesa distributed with XFree86 4.x or if we need to
# depend on the Mesa package.
# XFree86 starting with 4.1.0 contains now a libGLU, so also check for it.
.if (defined(CHECK_MESA) || defined(USE_MESA))
X11BASE?=		/usr/X11R6
.if exists(${X11BASE}/include/GL/glx.h)
__BUILTIN_MESA!=	${EGREP} -c BuildGLXLibrary ${X11BASE}/lib/X11/config/X11.tmpl || ${TRUE}
.else
__BUILTIN_MESA=		0
.endif
.if exists(${X11BASE}/include/GL/glu.h)
__BUILTIN_GLU!=		egrep -c BuildGLULibrary ${X11BASE}/lib/X11/config/X11.tmpl || true
.else
__BUILTIN_GLU=		0
.endif
.if ${__BUILTIN_MESA} == "0"
HAVE_BUILTIN_MESA=	NO
.else
HAVE_BUILTIN_MESA=	YES
.endif
.if ${__BUILTIN_GLU} == "0"
HAVE_BUILTIN_GLU=	NO
.else
HAVE_BUILTIN_GLU=	YES
.endif
.undef __BUILTIN_MESA
.undef __BUILTIN_GLU
.endif	# CHECK_MESA

# Check if we got FreeType2 distributed with XFree86 4.x or if we need to
# depend on the freetype2 package.
.if (defined(CHECK_FREETYPE2) || defined(USE_FREETYPE2))
X11BASE?=		/usr/X11R6
.if exists(${X11BASE}/include/freetype2/freetype/freetype.h)
__BUILTIN_FREETYPE2!=	${EGREP} -c BuildFreetype2Library ${X11BASE}/lib/X11/config/X11.tmpl || ${TRUE}
.else
__BUILTIN_FREETYPE2=	0
.endif
.if ${__BUILTIN_FREETYPE2} == "0"
HAVE_BUILTIN_FREETYPE2=	NO
.else
HAVE_BUILTIN_FREETYPE2=	YES
.endif
.undef __BUILTIN_FREETYPE2
.endif	# CHECK_FREETYPE2

# Check if we got Xpm distributed with XFree86 4.x or if we need to
# depend on the Xpm package.
.if (defined(CHECK_XPM) || defined(USE_XPM))
X11BASE?=		/usr/X11R6
.if exists(${X11BASE}/include/X11/xpm.h) && exists(${X11BASE}/lib/X11/config/X11.tmpl)
__BUILTIN_XPM!=		${EGREP} -c NormalLibXpm ${X11BASE}/lib/X11/config/X11.tmpl || ${TRUE}
.else
__BUILTIN_XPM=		0
.endif
.if ${__BUILTIN_XPM} == "0"
HAVE_BUILTIN_XPM=	NO
.else
HAVE_BUILTIN_XPM=	YES
.endif
.undef __BUILTIN_XPM
.endif	# CHECK_XPM

.if defined(USE_CURSES) && !defined(NEED_NCURSES)
NEED_NCURSES=		NO
.if ${OPSYS} == "NetBSD"
_INCOMPAT_CURSES=	0.* 1.[0123]* 1.4.* 1.4[A-X]
.for PATTERN in ${_INCOMPAT_CURSES}
.if ${OS_VERSION:M${PATTERN}} != ""
NEED_NCURSES=   	YES
.endif
.endfor
.endif
# we can NOT pass the NEED_NCURSES flag down as every required package
# will start to require ncurses, which is not true (and raises some
# recursive dependency problems!)
.endif # USE_CURSES


#
# list of serial port devices commonly found on various machines and
# which is the common default one.  This is used for semi-reasonable
# defaults on different machines.  These can and should be overridden
# on your machine in /etc/mk.conf.
# Please help fill in the list.
.if (${OPSYS} == "NetBSD")
.if (${MACHINE_ARCH} == alpha)
DEFAULT_SERIAL_DEVICE?=	/dev/ttyC0
SERIAL_DEVICES?=	/dev/ttyC0 \
			/dev/ttyC1
.elif (${MACHINE_ARCH} == "i386")
DEFAULT_SERIAL_DEVICE?=	/dev/tty00
SERIAL_DEVICES?=	/dev/tty00 \
			/dev/tty01
.elif (${MACHINE_ARCH} == m68k)
DEFAULT_SERIAL_DEVICE?=	/dev/tty00
SERIAL_DEVICES?=	/dev/tty00 \
			/dev/tty01
.elif (${MACHINE_ARCH} == mipsel)
DEFAULT_SERIAL_DEVICE?=	/dev/ttyC0
SERIAL_DEVICES?=	/dev/ttyC0 \
			/dev/ttyC1
.elif (${MACHINE_ARCH} == "sparc")
DEFAULT_SERIAL_DEVICE?=	/dev/ttya
SERIAL_DEVICES?=	/dev/ttya \
			/dev/ttyb
.else
DEFAULT_SERIAL_DEVICE?=	/dev/null
SERIAL_DEVICES?=	/dev/null
.endif  # ${MACHINE_ARCH}
.else   # ${OPSYS} != "NetBSD"
DEFAULT_SERIAL_DEVICE?=	/dev/null
SERIAL_DEVICES?=	/dev/null
.endif  # ${OPSYS} == "NetBSD"

##### Some overrides of defaults below on a per-OS basis.
.if (${OPSYS} == "NetBSD")
PKG_TOOLS_BIN?=		/usr/sbin
.elif (${OPSYS} == "SunOS")
LOCALBASE?=             ${DESTDIR}/usr/local
ZOULARISBASE?=		${LOCALBASE}/bsd
PKG_TOOLS_BIN?=		${ZOULARISBASE}/bin

.if (${X11BASE} == "/usr/openwin")
HAVE_OPENWINDOWS=	YES
.endif

.elif (${OPSYS} == "Linux")
ZOULARISBASE?=		${DESTDIR}/usr/local/bsd
PKG_TOOLS_BIN?=		${ZOULARISBASE}/bin
.endif

LOCALBASE?=		${DESTDIR}/usr/pkg
X11BASE?=		${DESTDIR}/usr/X11R6
CROSSBASE?=		${LOCALBASE}/cross

.ifndef DIGEST
DIGEST:=		${LOCALBASE}/bin/digest
MAKEFLAGS+=		DIGEST=${DIGEST}
.endif

# Only add the DIGEST_VERSION value to MAKEFLAGS when we know
# we've got a valid version number, retrieved from the digest(1)
# binary. This is different to PKGTOOLS_VERSION, since, in that
# case, the build dies when pkg_info(1) is out of date. 

.if !exists(${DIGEST})
DIGEST_VERSION=		20010301
.elif !defined(DIGEST_VERSION)
DIGEST_VERSION!= 	${DIGEST} -V 2>/dev/null
MAKEFLAGS+=		DIGEST_VERSION="${DIGEST_VERSION}"
.endif

.ifndef PKGTOOLS_VERSION
PKGTOOLS_VERSION!=${PKG_TOOLS_BIN}/pkg_info -V 2>/dev/null || echo 20010302
MAKEFLAGS+=	PKGTOOLS_VERSION="${PKGTOOLS_VERSION}"
.endif

.if (${OPSYS} == SunOS) && !defined(ZOULARIS_VERSION)
.if !exists(${ZOULARISBASE}/share/mk/zoularis.mk)
ZOULARIS_VERSION=	20000522
.else
.include "${ZOULARISBASE}/share/mk/zoularis.mk"
.endif
MAKEFLAGS+=		ZOULARIS_VERSION="${ZOULARIS_VERSION}"
.endif

.endif	# BSD_PKG_MK
