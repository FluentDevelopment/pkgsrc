#!/bin/sh
#
# $NetBSD: pkg_comp.sh,v 1.4 2002/12/24 16:28:34 jmmv Exp $
#
# pkg_comp - Build packages inside a clean chroot environment
# Copyright (c) 2002, Julio Merino <jmmv@netbsd.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name of author nor the names of its contributors may
#    be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

# ----------------------------------------------------------------------
# Misc functions
# ----------------------------------------------------------------------
err()
{
    echo "$progname: $1"
    exit 1
}

usage()
{
    echo "usage: $progname [-c conf_file] target [pkg_names]"
    exit 1
}

# ----------------------------------------------------------------------
# Filesystem functions
# ----------------------------------------------------------------------
fsmount()
{
    printf "PKG_COMP ==> Mounting chroot filesystems:"
    if [ -f $fsstate ]; then
        count=`cat $fsstate`
        count=$(($count + 1))
        echo "$count" > $fsstate
        echo " already mounted."
        return
    else
        echo "1" > $fsstate
    fi

    if [ -n "$REAL_SRC" ]; then
        if [ ! -d "$REAL_SRC" ]; then
            echo " failed."
            fsumount
            err "REAL_SRC $REAL_SRC disappeared"
        fi
        mount $REAL_SRC_OPTS $REAL_SRC $DESTDIR/usr/src
    fi

    if [ -n "$REAL_PKGSRC" ]; then
        if [ ! -d "$REAL_PKGSRC" ]; then
            echo " failed."
            fsumount
            err "REAL_PKGSRC $REAL_PKGSRC disappeared"
        fi
        mount $REAL_PKGSRC_OPTS $REAL_PKGSRC $DESTDIR/usr/pkgsrc
    fi

    if [ -n "$REAL_DISTFILES" ]; then
        if [ ! -d "$REAL_DISTFILES" ]; then
            echo " failed."
            fsumount
            err "REAL_DISTFILES $REAL_DISTFILES disappeared"
        fi
        mount $REAL_DISTFILES_OPTS $REAL_DISTFILES $DESTDIR/pkg_comp/distfiles
    fi

    if [ -n "$REAL_PACKAGES" ]; then
        if [ ! -d "$REAL_PACKAGES" ]; then
            echo " failed."
            fsumount
            err "REAL_PACKAGES $REAL_PACKAGES disappeared"
        fi
        mount $REAL_PACKAGES_OPTS $REAL_PACKAGES $DESTDIR/pkg_comp/packages
    fi

    touch $fsstate
    echo " done."
}

fsumount()
{
    printf "PKG_COMP ==> Unmounting chroot filesystems:"
    if [ ! -f $fsstate ]; then
        echo " none mounted."
        return
    fi

    count=`cat $fsstate`
    if [ $count -gt 1 ]; then
        count=$(($count - 1))
        echo "$count" > $fsstate
        echo " still in use."
        return
    fi

    fsfailed=no

    if [ -n "$REAL_SRC" -a -d "$REAL_SRC" ]; then
        umount $DESTDIR/usr/src
        if [ $? != 0 ]; then fsfailed=yes; fi
    fi

    if [ -n "$REAL_PKGSRC" -a -d "$REAL_PKGSRC" ]; then
        umount $DESTDIR/usr/pkgsrc
        if [ $? != 0 ]; then fsfailed=yes; fi
    fi

    if [ -n "$REAL_DISTFILES" -a -d "$REAL_DISTFILES" ]; then
        umount $DESTDIR/pkg_comp/distfiles
        if [ $? != 0 ]; then fsfailed=yes; fi
    fi

    if [ -n "$REAL_PACKAGES" -a -d "$REAL_PACKAGES" ]; then
        umount $DESTDIR/pkg_comp/packages
        if [ $? != 0 ]; then fsfailed=yes; fi
    fi

    echo " done."

    printf "Syncing: 1"
    sync ; sleep 1
    printf " 2"
    sync ; sleep 1
    printf " 3"
    sync ; sleep 1
    echo " done."
    if [ "$fsfailed" = "yes" ]; then
        err "FATAL: failed to umount all filesystems"
    else
        rm $fsstate
    fi
}

# ----------------------------------------------------------------------
# maketemplate target
# ----------------------------------------------------------------------
pkg_maketemplate()
{
    if [ -f "$conffile" ]; then
        err "$conffile already exists"
    fi

    echo "Creating template: $conffile"
    mkdir -p $confdir
    cat > $conffile <<EOF
# -*- sh -*-
#
# pkg_comp configuration file
#

DESTDIR="/var/chroot/pkg_comp/default"
ROOTSHELL="/bin/sh"
COPYROOTCFG="no"
COPTS="-pipe"

# Target used to build packages.
BUILD_TARGET="package"

# Binary sets (tgz) are found in \$DISTRIBDIR/binary/sets
DISTRIBDIR="/var/pub/NetBSD"

# These sets are unpacked to setup the initial chroot.
SETS="base.tgz comp.tgz etc.tgz text.tgz"

# X configuration. Leave SETS_X11 empty to disable X11.
SETS_X11="xbase.tgz xcomp.tgz xcontrib.tgz xfont.tgz xmisc.tgz xserver.tgz"
USE_XPKGWEDGE="yes"
USE_XF86_4="yes"

# pkgsrc configuration.
LOCALBASE="/usr/pkg"
PKG_SYSCONFBASE="\${LOCALBASE}/etc"

# Special directories. They are mounted inside the chroot jail using
# mount_null. Leave empty to avoid mounting.
REAL_SRC="/usr/src"
REAL_SRC_OPTS="-t null -o ro"
REAL_PKGSRC="/usr/pkgsrc"
REAL_PKGSRC_OPTS="-t null -o ro"
REAL_DISTFILES="/usr/pkgsrc/distfiles"
REAL_DISTFILES_OPTS="-t null -o rw"
REAL_PACKAGES="/usr/pkgsrc/packages"
REAL_PACKAGES_OPTS="-t null -o rw"

# Specify which packages to build automatically after building the chroot.
MAKE_PACKAGES=""

# Install these packages after building the chroot. They must be present in
# inside REAL_PACKAGES. You must specify the complete name.
INSTALL_PACKAGES=""

# Append this file to the generated mk.conf.
EXTRAMK=
EOF
}

# ----------------------------------------------------------------------
# makeroot target
# ----------------------------------------------------------------------
pkg_makeroot()
{
    # Check for directories that will be null mounted.
    if [ -n "$REAL_SRC" -a ! -d "$REAL_SRC" ]; then
        err "REAL_SRC $REAL_SRC does not exist"
    fi

    if [ -n "$REAL_PKGSRC" -a ! -d "$REAL_PKGSRC" ]; then
        err "REAL_PKGSRC $REAL_PKGSRC does not exist"
    fi

    if [ -n "$REAL_DISTFILES" -a ! -d "$REAL_DISTFILES" ]; then
        err "REAL_DISTFILES $REAL_DISTFILES does not exist"
    fi

    if [ -n "$REAL_PACKAGES" -a ! -d "$REAL_PACKAGES" ]; then
        err "REAL_PACKAGES $REAL_PACKAGES does not exist"
    fi

    # Check for required directories.
    if [ ! -d $DISTRIBDIR ]; then
        err "DISTRIBDIR $DISTRIBDIR does not exist"
    fi

    if [ -d $DESTDIR ]; then
        err "DESTDIR $DESTDIR already exists"
    fi
    mkdir -p $DESTDIR
    cd $DESTDIR

    printf "Unpacking sets:"
    allsets="$SETS $SETS_X11"
    for s in $allsets; do
        printf " $s"
        tar xzpf $DISTRIBDIR/binary/sets/$s
    done
    echo

    printf "Making device nodes:"
    cd $DESTDIR/dev
    ./MAKEDEV all
    cd $DESTDIR
    echo " done."

    printf "Setting root's environment:"
    chroot $DESTDIR chpass -s $ROOTSHELL
    if [ "$COPYROOTCFG" = "yes" ]; then
        cp /root/.* $DESTDIR/root 2>&1 | > /dev/null
    fi
    echo " done."

    printf "Setting up initial configuration:"

    mkdir -p $DESTDIR/usr/src
    mkdir -p $DESTDIR/usr/pkgsrc
    mkdir -p $DESTDIR/pkg_comp/distfiles
    mkdir -p $DESTDIR/pkg_comp/packages
    mkdir -p $DESTDIR/pkg_comp/tmp
    mkdir -p $DESTDIR/pkg_comp/obj/pkgsrc

    # Set sh configuration
    echo "umask 022" >> $DESTDIR/etc/profile
    echo "ENV=/etc/shrc" >> $DESTDIR/etc/profile
    echo "export PS1=\"pkg_comp:`basename $conffile`# \"" >> $DESTDIR/etc/shrc

    # Set csh configuration
    echo "umask 022" >> $DESTDIR/etc/csh.login
    echo "set prompt=\"pkg_comp:`basename $conffile`# \"" >> $DESTDIR/etc/csh.login
    echo "set prompt=\"pkg_comp:`basename $conffile`# \"" >> $DESTDIR/etc/csh.cshrc

    cp /etc/resolv.conf $DESTDIR/etc/resolv.conf

    makeroot_mkconf

    echo " done."

    makeroot_xpkgwedge

    if [ -n "$MAKE_PACKAGES" ]; then
        pkg_build $MAKE_PACKAGES
    fi

    if [ -n "$INSTALL_PACKAGES" ]; then
        pkg_install $INSTALL_PACKAGES
    fi
}

makeroot_mkconf()
{
    file="$DESTDIR/etc/mk.conf"

    echo "OBJMACHINE=yes" >> $file
    echo "MKOBJDIRS=yes" >> $file
    echo "BSDSRCDIR=/usr/src" >> $file
    echo "WRKOBJDIR=/pkg_comp/obj/pkgsrc" >> $file
    echo "DISTDIR=/pkg_comp/distfiles" >> $file
    echo "PACKAGES=/pkg_comp/packages" >> $file
    echo "PKG_DEVELOPER?=yes" >> $file
    echo "CLEANDEPENDS?=yes" >> $file

    echo "COPTS=$COPTS" >> $file
    echo "USE_XF86_4=$USE_XF86_4" >> $file

    echo "LOCALBASE=$LOCALBASE" >> $file
    echo "PKG_SYSCONFBASE=$PKG_SYSCONFBASE" >> $file

    if [ ! -f "$EXTRAMK" ]; then
        err "Cannot find $EXTRAMK"
    fi
    cat $EXTRAMK >> $file
}

makeroot_xpkgwedge()
{
    if [ -n "$SETS_X11" ]; then
        if [ $USE_XPKGWEDGE = "yes" ]; then
            pkg_build "pkgtools/xpkgwedge"
            echo "export XAPPLRESDIR=${LOCALBASE}/lib/X11/app-defaults" >> $DESTDIR/etc/profile
            echo "setenv XAPPLRESDIR ${LOCALBASE}/lib/X11/app-defaults" >> $DESTDIR/etc/csh.login
        fi
    fi
}

# ----------------------------------------------------------------------
# build target
# ----------------------------------------------------------------------
pkg_build()
{
    pkgs="$*"

    # Check if all packages exist
    invalid=""
    for p in $pkgs; do
        if [ ! -d $REAL_PKGSRC/$p ]; then
            invalid="$invalid $p"
        fi
    done
    if [ -n "$invalid" ]; then
        err "invalid packages:$invalid"
    fi

    # Build them
    fsmount
    failed=""
    for p in $pkgs; do
        echo "PKG_COMP ==> Building and installing $p"
        prefix=`mktemp $DESTDIR/pkg_comp/tmp/pkg_comp-XXXX`
        rm $prefix
        script="$prefix.sh"
        statfile="$prefix.stat"
        cat > $script <<EOF
#!/bin/sh
cd /usr/pkgsrc/$p
make $BUILD_TARGET
if [ \$? != 0 ]; then
    touch /pkg_comp/tmp/`basename $statfile`
fi
make clean
EOF
        chmod +x $script
        chroot $DESTDIR /pkg_comp/tmp/`basename $script`
        rm $script
        if [ -f $statfile ]; then
            failed="$failed $p"
            rm $statfile
        fi
    done
    fsumount
    if [ -n "$failed" ]; then
        echo "PKG_COMP ==> Build error summary"
        echo "Build failed for:"
        for p in $failed; do
            echo "    $p"
        done
    fi
}

# ----------------------------------------------------------------------
# install target
# ----------------------------------------------------------------------
pkg_install()
{
    pkgs="$*"

    if [ -z "$REAL_PACKAGES" ]; then
        err "REAL_PACKAGES is not set"
    fi

    fsmount
    failed=""
    for p in $pkgs; do
        if [ -f $DESTDIR/pkg_comp/packages/All/$p ]; then
            echo "PKG_COMP ==> Installing binary package: $p"
            stat=$DESTDIR/pkg_comp/tmp/install.sh
            cat >> $stat <<EOF
#!/bin/sh
cd /pkg_comp/packages/All
pkg_add $p
EOF
            chmod +x $stat
            chroot $DESTDIR /pkg_comp/tmp/install.sh
            rm $stat
        else
            failed="$failed $p"
        fi
    done
    fsumount
    if [ -n "$failed" ]; then
        echo "Installation failed for:$failed"
    fi
}

# ----------------------------------------------------------------------
# chroot target
# ----------------------------------------------------------------------
pkg_chroot()
{
    if [ ! -d $DESTDIR ]; then
        err "$DESTDIR does not exist"
    fi

    fsmount
    echo "PKG_COMP ==> Entering chroot: $DESTDIR"
    chroot $DESTDIR $ROOTSHELL
    echo
    fsumount
}

# ----------------------------------------------------------------------
# removeroot target
# ----------------------------------------------------------------------
pkg_removeroot()
{
    if [ -f $fsstate ]; then
        err "filesystems may still be mounted; cannot remove"
    fi
    printf "PKG_COMP ==> Removing chroot:"
    rm -rf $DESTDIR
    echo " done."
}

# ----------------------------------------------------------------------
# removepkgs target
# ----------------------------------------------------------------------
pkg_removepkgs()
{
    fsmount
    echo "PKG_COMP ==> Removing packages"
    cat > $DESTDIR/pkg_comp/tmp/removeall.sh <<EOF
#!/bin/sh
list="\`pkg_info\`"
while [ -n "\$list" ]; do
    echo "Deleting all (non-recursive)"
    pkg_delete "*"
    list="\`pkg_info\`"
done
EOF
    chmod +x $DESTDIR/pkg_comp/tmp/removeall.sh
    chroot $DESTDIR /pkg_comp/tmp/removeall.sh
    rm $DESTDIR/pkg_comp/tmp/removeall.sh

    printf "Cleaning pkg tree ($LOCALBASE):"
    rm -rf $DESTDIR$LOCALBASE
    echo " done."

    if [ -d "$PKG_SYSCONFBASE" ]; then
        printf "Cleaning pkg configuration ($PKG_SYSCONFBASE):"
        rm -rf $DESTDIR$PKG_SYSCONFBASE
        echo " done."
    fi

    printf "Cleaning pkg database:"
    rm -rf $DESTDIR/var/db/pkg
    mkdir -p $DESTDIR/var/db/pkg
    echo " done."
    makeroot_xpkgwedge
    if [ -n "$MAKE_PACKAGES" ]; then
        pkg_build $MAKE_PACKAGES
    fi
    if [ -n "$INSTALL_PACKAGES" ]; then
        pkg_install $INSTALL_PACKAGES
    fi
    fsumount
}

# ----------------------------------------------------------------------
# Main program
# ----------------------------------------------------------------------

progname="`basename $0`"
confdir="$HOME/pkg_comp"

# Parse options
args=`getopt c: $*`
if [ $? != 0 ]; then
    usage
fi
set -- $args
conffile="$confdir/default.conf"
while [ $# -gt 0 ]; do
    case "$1" in
        -c)
            conffile="$confdir/$2.conf"
            shift
            ;;
        --)
            shift; break
            ;;
    esac
    shift
done

if [ $# -lt 1 ]; then
    usage
fi

target="$1"
shift
pkgnames="$*"

readconf()
{
    if [ -f $conffile ]; then
        if [ `id -u` -ne 0 ]; then
            err "must be run as root"
        fi
        echo "Reading config file: $conffile"
        . $conffile
    else
        err "$conffile does not exist"
    fi

    if [ -z "$LOCALBASE" ]; then
        LOCALBASE="/usr/pkg"
    fi

    if [ -z "$PKG_SYSCONFBASE" ]; then
        PKG_SYSCONFBASE="/usr/pkg/etc"
    fi

    fsstate="$DESTDIR/pkg_comp/tmp/mount.stat"

    if [ -n "$SETS_X11" ]; then
        MAKE_PACKAGES="$MAKE_PACKAGES pkgtools/x11-links"
    fi
}

checkroot()
{
   if [ ! -d "$DESTDIR" ]; then
       err "chroot not initialized; use makeroot first."
   fi
   if [ "$DESTDIR" = "/" ]; then
       err "DESTDIR cannot be /"
   fi

   # From now on, filesystems may be mounted, so we need to trap
   # signals to umount them.
   trap "echo \"*** Process aborted ***\" ; fsumount ; exit 1" INT QUIT
}

case "$target" in
    maketemplate)
        pkg_maketemplate
        exit 0
        ;;
    makeroot)
        readconf
        pkg_makeroot
        exit 0
        ;;
    build)
        readconf
        checkroot
        pkg_build $pkgnames
        exit 0
        ;;
    install)
        readconf
        checkroot
        pkg_install $pkgnames
        exit 0
        ;;
    chroot)
        readconf
        checkroot
        pkg_chroot
        exit 0
        ;;
    removepkgs)
        readconf
        checkroot
        pkg_removepkgs
        ;;
    removeroot)
        readconf
        checkroot
        pkg_removeroot
        ;;
    auto)
        readconf
        BUILD_TARGET="package"
        if [ -z "$REAL_PACKAGES" ]; then
            err "this is useless without REAL_PACKAGES"
        fi
        if [ -z "$MAKE_PACKAGES" -a -z "$pkgnames" ]; then
            err "this is useless without MAKE_PACKAGES nor package names"
        fi
        pkg_makeroot
        checkroot
        if [ -n "$pkgnames" ]; then
            pkg_build $pkgnames
        fi
        pkg_removeroot
        ;;
    *)
        err "unknown target '$target'"
        ;;
esac

exit 0

