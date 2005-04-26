# $NetBSD: texinfo.mk,v 1.3 2005/04/26 15:32:05 jlam Exp $

# Create an install-info script that is a "no operation" command, as
# registration of info files is handled by the INSTALL script.
#
TOOLS_NOOP+=		install-info
CONFIGURE_ENV+=		INSTALL_INFO=${TOOLS_CMD.install-info:Q}
MAKE_ENV+=		INSTALL_INFO=${TOOLS_CMD.install-info:Q}

# Create a makeinfo script that will invoke the right makeinfo command
# if USE_MAKEINFO is "yes" or will exit on error if not.  MAKEINFO is
# defined by mk/texinfo.mk if USE_MAKEINFO is "yes".
#
USE_MAKEINFO?=			no
.if empty(USE_MAKEINFO:M[nN][oO])
TOOLS_WRAP+=			makeinfo
TOOLS_REAL_CMDLINE.makeinfo=	${MAKEINFO}
.else
TOOLS_BROKEN+=			makeinfo
.endif
CONFIGURE_ENV+=			MAKEINFO=${TOOLS_CMD.makeinfo:Q}
MAKE_ENV+=			MAKEINFO=${TOOLS_CMD.makeinfo:Q}
