# $NetBSD: defs.OpenBSD.mk,v 1.10 2002/12/16 09:18:57 salo Exp $
#
# Variable definitions for the OpenBSD operating system.

AWK?=		/usr/bin/awk
BASENAME?=	/usr/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/bin/chgrp
CMP?=		/usr/bin/cmp
CP?=		/bin/cp
CUT?=		/usr/bin/cut
DATE?=		/bin/date
DC?=		/usr/bin/dc
DIRNAME?=	/usr/bin/dirname
ECHO?=		echo				# Shell builtin
EGREP?=		/usr/bin/egrep
EXPR?=		/bin/expr
FGREP?=		/usr/bin/fgrep
FALSE?=		false				# Shell builtin
FILE_CMD?=	/usr/bin/file
FIND?=		/usr/bin/find
GMAKE?=		${LOCALBASE}/bin/gmake
GREP?=		/usr/bin/grep
.if exists(/bin/tar)
GTAR?=		/bin/tar
.else
GTAR?=		/usr/bin/tar
.endif
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/usr/bin/gzcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
HEAD?=		/usr/bin/head
ID?=		/usr/bin/id
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
LS?=		/bin/ls
MKDIR?=		/bin/mkdir -p
MTREE?=		/usr/sbin/mtree
MV?=		/bin/mv
NICE?=		/usr/bin/nice
PATCH?=		/usr/bin/patch
PAX?=		/bin/pax
PERL5?=		${LOCALBASE}/bin/perl
PKGLOCALEDIR?=	share
PS?=		/bin/ps
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SHLOCK=		${LOCALBASE}/bin/shlock
SORT?=		/usr/bin/sort
SU?=		/usr/bin/su
TAIL?=		/usr/bin/tail
TEE?=		/usr/bin/tee
TEST?=		test				# Shell builtin
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		true				# Shell builtin
TSORT?=		/usr/bin/tsort
TYPE?=		type				# Shell builtin
WC?=		/usr/bin/wc
XARGS?=		/usr/bin/xargs

.if exists(/usr/sbin/user)
USERADD?=	/usr/sbin/useradd
GROUPADD?=	/usr/sbin/groupadd
.else
USERADD?=	${LOCALBASE}/sbin/useradd
GROUPADD?=	${LOCALBASE}/sbin/groupadd
.if defined(USE_USERADD) || defined(USE_GROUPADD)
DEPENDS+=	user>=20000313:../../sysutils/user
.endif
.endif

CPP_PRECOMP_FLAGS?=	# unset
DEF_UMASK?=		0022
.if ${OBJECT_FMT} == "ELF"
EXPORT_SYMBOLS_LDFLAGS?=-Wl,-E	# add symbols to the dynamic symbol table
.else
EXPORT_SYMBOLS_LDFLAGS?=-Wl,--export-dynamic
.endif
MOTIF_TYPE_DEFAULT?=	openmotif	# default 2.0 compatible libs type
MOTIF12_TYPE_DEFAULT?=	lesstif12	# default 1.2 compatible libs type
NOLOGIN?=		/sbin/nologin
PKG_TOOLS_BIN?=		${LOCALBASE}/sbin
ROOT_CMD?=		${SU} - root -c
ROOT_USER?=		root
ROOT_GROUP?=	wheel
ULIMIT_CMD_datasize?=	ulimit -d `ulimit -H -d`
ULIMIT_CMD_stacksize?=	ulimit -s `ulimit -H -s`
ULIMIT_CMD_memorysize?=	ulimit -m `ulimit -H -m`

_DO_SHLIB_CHECKS=	yes	# fixup PLIST for shared libs/run ldconfig
_IMAKE_MAKE=		${MAKE}	# program which gets invoked by imake
_OPSYS_HAS_GMAKE=	no	# GNU make is not standard
_OPSYS_HAS_JAVA=	no	# Java is not standard
_OPSYS_HAS_MANZ=	yes	# MANZ controls gzipping of man pages
_OPSYS_HAS_OSSAUDIO=	yes	# libossaudio is available
_OPSYS_LIBTOOL_REQD=	1.4.20010614nb9 # base version of libtool required
_OPSYS_PERL_REQD=		# no base version of perl required
_OPSYS_RPATH_NAME=	-R	# name of symbol in rpath directive to linker 
_PATCH_CAN_BACKUP=	yes	# native patch(1) can make backups
_PATCH_BACKUP_ARG=	-V simple -b 	# switch to patch(1) for backup suffix
_PREFORMATTED_MAN_DIR=	cat	# directory where catman pages are
_USE_GNU_GETTEXT=	no	# Don't use GNU gettext
_USE_RPATH=		yes	# add rpath to LDFLAGS

.if !defined(DEBUG_FLAGS)
_STRIPFLAG_CC?=		-s	# cc(1) option to strip
_STRIPFLAG_INSTALL?=	-s	# install(1) option to strip
.endif

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
.elif (${MACHINE_ARCH} == "sparc")
DEFAULT_SERIAL_DEVICE?=	/dev/ttya
SERIAL_DEVICES?=	/dev/ttya \
			/dev/ttyb
.else
DEFAULT_SERIAL_DEVICE?=	/dev/null
SERIAL_DEVICES?=	/dev/null
.endif
