#!/bin/sh
#
# $NetBSD: mklivecd.sh,v 1.35 2007/04/10 20:52:01 xtraeme Exp $
#
# Copyright (c) 2004-2007 Juan Romero Pardines.
# All rights reserved.
#
# This code is derived from software contributed to The NetBSD Foundation
# by Juan Romero Pardines.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#        This product includes software developed by the NetBSD
#        Foundation, Inc. and its contributors.
# 4. Neither the name of The NetBSD Foundation nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
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
# ======================================================================== #
#  mklivecd - Make your own NetBSD/x86 Live CD-ROM/DVD-ROM                #
# ======================================================================== #

: ${progname:=$(basename $0)}
: ${config_dir:=$HOME/.mklivecd}
: ${pers_conffile:=personal_config}
: ${tmp_file:=$(/usr/bin/mktemp /tmp/${progname}.XXXXXX)}
: ${pkgsrc_mntstat:=$config_dir/pkgsrc_mount.stat}
: ${pkgsrcdist_mntstat:=$config_dir/pkgsrcdist_mount.stat}
: ${packages_mntstat:=$config_dir/packages_mount.stat}

#
# Neeeded to disable GRUB on amd64.
#
: ${ARCH:=$(/sbin/sysctl -n hw.machine_arch)}

#
# NetBSD >= 4.0 has bootxx_cd9660, no need to use grub here.
#
: ${CDBOOT_IMG:=bootxx_cd9660}
: ${BOOT_IMG:=boot}
: ${CDBOOT_DIR:=/usr/mdec}
#
# Don't modify the next ones! they are needed for booting grub.
#
: ${GRUB_BOOTDIR:=boot/grub}
: ${GRUB_BOOTIMAGE:=stage2_eltorito}
: ${GRUB_FILES:=stage1 stage2 stage2_eltorito iso9660_stage1_5 \
                xfs_stage1_5 ufs2_stage1_5 reiserfs_stage1_5 \
                jfs_stage1_5 ffs_stage1_5 fat_stage1_5 e2fs_stage1_5}
: ${GRUB_BOOT_ARGS:= -boot-load-size 30 -boot-info-table}
#
# Common vars for cdboot/grub.
#
: ${MKISOFS_FIXED_ARGS:=-no-emul-boot}

trap "echo; showmsg \"PROCESS CANCELLED!\"; bye 127" INT QUIT

# ====================================================================== #
#  My functions :-)							 #
# ====================================================================== #

usage()
{
    cat <<_usage_

    ${progname}: [-v] [-c config_file] [-k kernel] [target]

	Target operations:

        base    Install the base/x11 sets into ISODIR
        burn    Burn the ISO9660 image with cdrecord(1)
        chroot  Chroot into the livecd
        clean   Clean the WORKDIR and ISODIR directories
        config  Create default configuration file
        fetch   Download base/x11 sets from REMOTE_SETS_URL
        iso     Build the ISO9660 image with mkisofs(1)
	kernel  Build and install the kernel(s) and boot files

_usage_

    exit 1
}

showmsg()
{
    echo "===> $@"
}

showmsg_n()
{
    echo -n "===> $@"
}

showmsgstring()
{
    if [ "$?" -eq 0 ]; then
	echo " done."
    else
	echo " failed."
    fi
}

is_enabled()
{
    eval _val="\$$1"

    case $_val in
        [Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_disabled()
{
    eval _val="\$$1"

    case $_val in
        [Nn][Oo])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

bye()
{
    _exitarg="$1"
    rm -f $tmp_file; exit $_exitarg
}

do_conf()
{
    BASE_VARS="SOURCEDIR PACKAGESDIR PKGSRCDIR PKGSRCDISTDIR SHAREDIR BASEDIR \
               WORKDIR ISODIR FETCH_SETS REMOTE_SETS_URL BASE_SETS_DIR \
               X11_SETS_DIR BASE_SETS X11_SETS CHROOT_SHELL"

    KERNEL_VARS="MULTIPLE_KERNELS KERNEL_CONFIG KERNEL_NAME"

    MISC_VARS="ENABLE_X11 MKISOFS_BIN MKISOFS_ARGS CDRECORD_BIN CDRECORD_ARGS \
               BLANK_BEFORE_BURN CDROM_DEVICE PERSONAL_CONFIG IMAGE_NAME \
               PKG_SYSCONFDIR REMOVE_DIRS HOSTNAME VND_COMPRESSION \
               USE_GNU_GRUB GRUB_FILES_DIR"

    if [ "${ARCH}" = "x86_64" ]; then
        ARCH="amd64"
    fi

    MNT_VARS="MNT_RAMFS_CMD MNT_RAMFS_ARGS"

    # Base directories/sets
    : ${SOURCEDIR:=/usr/src}
    : ${PACKAGESDIR:=/usr/pkgsrc/packages}
    : ${PKGSRCDIR:=/usr/pkgsrc}
    : ${PKGSRCDISTDIR:=/usr/pkgsrc/distfiles}
    : ${SHAREDIR:=@PREFIX@/share/mklivecd}
    : ${BASEDIR:=$HOME/livecd}
    : ${WORKDIR:=${BASEDIR}/work}
    : ${ISODIR:=${BASEDIR}/iso}
    : ${FETCH_SETS:=no}
    : ${REMOTE_SETS_URL:=ftp://ftp.NetBSD.org/pub/NetBSD/NetBSD-3.1/${ARCH}/binary/sets}
    : ${BASE_SETS_DIR:=$HOME/release/binary/sets}
    : ${X11_SETS_DIR:=${BASE_SETS_DIR}}
    : ${BASE_SETS:=etc.tgz base.tgz comp.tgz text.tgz}
    : ${X11_SETS:=xbase.tgz xcomp.tgz xfont.tgz xserver.tgz}
    : ${CHROOT_SHELL:=/bin/ksh}
    : ${HOSTNAME:=MKLIVECD_0x00}

    # kernel options
    : ${MULTIPLE_KERNELS:=no}
    : ${KERNEL_CONFIG:=KERN-LIVECD}
    : ${KERNEL_NAME:=MKLIVECD}

    # Miscellaneous options
    : ${ENABLE_X11:=no}
    : ${MKISOFS_BIN:=@PREFIX@/bin/mkisofs}
    : ${MKISOFS_ARGS:=-J -R -nobak -v}
    : ${CDRECORD_BIN:=@PREFIX@/bin/cdrecord}
    : ${CDRECORD_ARGS:=-v}
    : ${BLANK_BEFORE_BURN:=no}
    : ${CDROM_DEVICE:=15,1,0}
    : ${PERSONAL_CONFIG:=no}
    : ${IMAGE_NAME:=NetBSD-LiveCD}
    : ${PKG_SYSCONFDIR:=usr/pkg/etc}
    : ${REMOVE_DIRS:=altroot usr/share/info}
    : ${USE_GNU_GRUB:=yes}
    : ${GRUB_FILES_DIR:=@LOCALBASE@/lib/grub/@MACHINE_ARCH@-}
    : ${VND_COMPRESSION:=no}
    #	
    # Mount arguments
    #
    : ${MNT_RAMFS_CMD:=mount_mfs}
    : ${MNT_RAMFS_ARGS:=-s 128m swap}

    [ ! -d $config_dir ] && mkdir $config_dir

    [ ! -f $config_dir/$pers_conffile ] && \
        cp $SHAREDIR/$pers_conffile $config_dir

    if [ ! -f $config_file ]; then
	cat >> $config_file <<EOF
# --*-sh-*--    
#               
# mklivecd - configuration file
# See mklivecd(8) for a detailed description of each variable.
#
# Generated automatically on $(date).

EOF
	echo "# Base directories/options" >> $config_file
	for var in $(echo $BASE_VARS | tr ' ' '\n' | sort -u)
	do
		eval val=\""\$$var"\"
		echo "$var=\"$val\"" >> $config_file
	done
	echo >> $config_file

	echo "# kernel options" >> $config_file
	for var in $(echo $KERNEL_VARS | tr ' ' '\n' | sort -u)
	do
		eval val=\""\$$var"\"
		echo "$var=\"$val\"" >> $config_file
	done
	echo >> $config_file
        (   \
        echo "# MULTIPLE_KERNELS example:"; \
        echo "#";   \
        echo "# MULTIPLE_KERNELS=\"ACPI APM\""; \
        echo "# KERNEL_CONFIG_ACPI=\"KERN_ACPI\"";   \
        echo "# KERNEL_NAME_ACPI=\"LIVECD_ACPI\"";  \
        echo "# KERNEL_CONFIG_APM=\"KERN_APM\""; \
        echo "# KERNEL_NAME_APM=\"LIVECD_APM\"";    \
        ) >> $config_file
        echo >> $config_file

        [ "${ARCH}" != "i386" ] && USE_GNU_GRUB=no

	echo "# Miscellaneous options" >> $config_file
	for var in $(echo $MISC_VARS | tr ' ' '\n' | sort -u)
	do
		eval val=\""\$$var"\"
		echo "$var=\"$val\"" >> $config_file
	done
	echo >> $config_file

	echo "# Mount arguments" >> $config_file
	for var in $(echo $MNT_VARS | tr ' ' '\n' | sort -u)
	do
		eval val=\""\$$var"\"
		echo "$var=\"$val\"" >> $config_file
	done
	echo >> $config_file

	echo "=> Configuration file created, now please edit it."
	echo "=> Path: $config_file"
    elif [ -f $config_file -a $target != "config" ]; then
        [ -n "$verbose_mode" ] && showmsg "Using $config_file"
    else
        showmsg "$config_file already exists!"
        bye 1
    fi
}

do_conf_reset()
{
    for F in ${BASE_VARS} ${MISC_VARS} ${MNT_VARS}
    do
        eval $F=\"\"
    done
}

copy_bootfiles()
{
    #
    # GNU GRUB.
    #
    if is_enabled USE_GNU_GRUB; then
        [ ! -d $ISODIR/$GRUB_BOOTDIR ] && mkdir -p $ISODIR/$GRUB_BOOTDIR
	for f in $GRUB_FILES
        do
            if [ ! -f $ISODIR/$GRUB_BOOTDIR/$f ]; then
                if [ -f $GRUB_FILES_DIR/$f ]; then
                    cp $GRUB_FILES_DIR/$f $ISODIR/$GRUB_BOOTDIR
                    [ -n "$verbose_mode" ] && \
                        showmsg "Copying $f into $ISODIR/$GRUB_BOOTDIR"
                else
                    echo "=> File $f not found!"
                fi
            else
                echo "=> Not copying $f, already exists."
            fi
        done
    else
    #
    # NetBSD cd9660 bootloader (bootxx_cd9660)
    #
        if [ -f ${CDBOOT_DIR}/${CDBOOT_IMG} ]; then
            cp -f ${CDBOOT_DIR}/${CDBOOT_IMG} $ISODIR
        else
            echo "=> Missing cdboot... exiting."
            bye 1
        fi

        if [ -f ${CDBOOT_DIR}/${BOOT_IMG} ]; then
            cp -f ${CDBOOT_DIR}/${BOOT_IMG} $ISODIR
        else
            echo "=> Missing boot... exiting."
        fi
    fi
}

do_menu_lst()
{
    if [ -f $ISODIR/$GRUB_BOOTDIR/menu.lst ]; then
        showmsg_n "Updating menu.lst..."
        (   \
        echo "title NetBSD/$KERNEL_NAME kernel";   \
        echo "kernel --type=netbsd /$GRUB_BOOTDIR/$KERNEL_CONFIG.gz"; \
        echo;   \
        ) >> $ISODIR/$GRUB_BOOTDIR/menu.lst
    else
        [ -n "$verbose_mode" ] && \
            showmsg_n "Creating $ISODIR/$GRUB_BOOTDIR/menu.lst..."
        cat > $ISODIR/$GRUB_BOOTDIR/menu.lst << _EOF_
# Default GRUB menu file created by ${progname}.
# Date: $(date).

default 0
timeout 10

title NetBSD/$KERNEL_NAME kernel
kernel --type=netbsd /$GRUB_BOOTDIR/$KERNEL_CONFIG.gz

_EOF_
        showmsgstring
    fi
}

do_build_kernels()
{
    . $config_file

    for K in ${MULTIPLE_KERNELS}
    do
        eval bootkern=\$KERNEL_CONFIG_${K}
        eval kernname=\$KERNEL_NAME_${K}

        cd $WORKDIR
        showmsg "Building kernel: $bootkern.."

        [ -s $config_dir/$bootkern ] && \
            cp $config_dir/$bootkern $WORKDIR

        if [ ! -d $WORKDIR/$kernname ]; then
            mkdir $WORKDIR/$kernname
	fi

	if [ ! -d $WORKDIR/$kernname -a ! -f $bootkern ]; then
	    showmsg "Missing files... exiting."
	    bye 1
	fi

	config -s $SOURCEDIR/sys -b $WORKDIR/$kernname $bootkern
	cd $kernname
	make depend && make
	if [ "$?" -eq 0 ]; then
            if is_enabled USE_GNU_GRUB; then
                cp $WORKDIR/$kernname/netbsd $ISODIR/$GRUB_BOOTDIR/$bootkern
            else
                cp $WORKDIR/$kernname/netbsd $ISODIR/$bootkern
            fi
            [ -n "$verbose_mode" ] && \
                showmsg_n "Compressing kernel $bootkern..."
            
            if is_enabled USE_GNU_GRUB; then
                gzip $ISODIR/$GRUB_BOOTDIR/$bootkern
                showmsgstring
		if [ -f $ISODIR/$GRUB_BOOTDIR/menu.lst ]; then
		    showmsg_n "Updating menu.lst..."
                    (   \
                    echo "title NetBSD/$kernname kernel";   \
                    echo "kernel --type=netbsd /$GRUB_BOOTDIR/$bootkern.gz"; \
                    echo;   \
                    ) >> $ISODIR/$GRUB_BOOTDIR/menu.lst
		else
		    showmsg_n "Creating grub menu.lst..."
		    cat >> $ISODIR/$GRUB_BOOTDIR/menu.lst << _EOF_
# Default GRUB menu file created by ${progname}.
# Date: $(date).

default 0
timeout 10

title NetBSD/$kernname kernel
kernel --type=netbsd /$GRUB_BOOTDIR/$bootkern.gz

_EOF_
		fi
		    showmsgstring
            else
                gzip $ISODIR/$bootkern
                showmsgstring
            fi
        else
            echo "=> kernel compilation failed! ($kernname)"
            bye 1
        fi
    done
}

do_cdlive()
{
    . $config_file

    vars="$BASEDIR $ISODIR $WORKDIR"

    for value in $vars
    do
        [ ! -d $value ] && mkdir -p $value
    done

    case "$1" in
    kernel)
        if [ ! -d $SOURCEDIR/sys ]; then
            echo "=> CANNOT FIND THE NETBSD SOURCES, EXITING!"
            bye 1
	fi

        # if -k was specified, override values on config file.
        if [ -n "$K_ARG_SET" ]; then
            KERNEL_CONFIG=$kernel_arg
            KERNEL_NAME=MKLIVECD_$kernel_arg
        fi

        if is_disabled MULTIPLE_KERNELS; then
	    showmsg "Building kernel on $(date):"
	    if [ -n "$verbose_mode" ]; then
                echo
		showmsg "Using kernel: $KERNEL_CONFIG"
		showmsg "Kernel name: $KERNEL_NAME"
		sleep 2
		fi
		echo
                #
                # Use the specified kernel from ~/.mklivecd.
                #
		if [ -s $config_dir/$KERNEL_CONFIG ]; then
		    cp $config_dir/$KERNEL_CONFIG $WORKDIR
                else
                    echo "=> CANNOT FIND '$KERNEL_CONFIG' in $config_dir, EXITING!"
                    bye 1
                fi

		cd $WORKDIR
		    [ ! -d $WORKDIR/$KERNEL_NAME ] && \
			mkdir $WORKDIR/$KERNEL_NAME
		    config -s $SOURCEDIR/sys -b $WORKDIR/$KERNEL_NAME \
		        $KERNEL_CONFIG
		cd $KERNEL_NAME
		make depend && make
		if [ "$?" -eq 0 ]; then
		    copy_bootfiles
		    showmsg_n "Compressing kernel $KERNEL_CONFIG..."
                    if is_enabled USE_GNU_GRUB; then
		        cp $WORKDIR/$KERNEL_NAME/netbsd \
			    $ISODIR/$GRUB_BOOTDIR/$KERNEL_CONFIG
			gzip -9 $ISODIR/$GRUB_BOOTDIR/$KERNEL_CONFIG
			showmsgstring
                    else
                        if [ -f $ISODIR/netbsd ]; then
                        #
                        # ISO9660 specifies that ISO Level 1 cannot handle
                        # filenames with > 8 characters... actually the
                        # cd9660.c standalone file-system for the bootloader
                        # does not support ISO Level 2/3.
                        #
                        # Note too that '-' is not an allowed character, so
                        # is better to use a dot '.' .
                        #
                        # I'll change this when cd9660.c is fixed.
                        #
                            cp $WORKDIR/$KERNEL_NAME/netbsd \
                                $ISODIR/k.$KERNEL_CONFIG
			    gzip -9 $ISODIR/k.$KERNEL_CONFIG
                            mv $ISODIR/k.$KERNEL_CONFIG.gz \
                                $ISODIR/k.$KERNEL_CONFIG
                        else
                            cp $WORKDIR/$KERNEL_NAME/netbsd $ISODIR
                            gzip -9 $ISODIR/netbsd
                            mv $ISODIR/netbsd.gz $ISODIR/netbsd
                        fi
			showmsgstring
                    fi
		    if [ "$?" -eq 0 ]; then
                        is_enabled USE_GNU_GRUB && do_menu_lst
		        [ -n "$verbose_mode" ] && \
		            echo "=> NEXT STEP: ${progname} base"
		    else
			echo "=> COULDN'T INSTALL THE KERNEL(S)"
		    fi
		else
		    echo
		    showmsg "Target kernel failed."
		    bye 1
		fi
            else
                copy_bootfiles
                do_build_kernels
            fi
	;;
    fetch)
        #
        # Fetch the sets if the option is enabled from REMOTE_SETS_URL.
        #
        if is_enabled FETCH_SETS; then
            if [ ! -d $BASE_SETS_DIR ]; then
                showmsg "Cannot find $BASE_SETS_DIR, exiting"
                bye 1
            fi 
            cd $BASE_SETS_DIR
            for f in ${BASE_SETS}
            do
                if [ -f "$f" ]; then
                    echo -n "There's already '$f', do you want to "
                    echo -n "download it again? (y/n) "
                    read output_u
                    if [ "$output_u" = "y" ]; then
                        rm "$f"
                    elif [ "$output_u" = "n" -o "$output_u" != "y" ]; then
                           continue
                    fi
                fi

                if [ -n "$verbose_mode" ]; then
                    /usr/bin/ftp -4a "$REMOTE_SETS_URL/$f"
                else
                    showmsg_n "Downloading set $f..."
                    /usr/bin/ftp -4a "$REMOTE_SETS_URL/$f" 2>&1 > /dev/null
                    showmsgstring
                fi
            done
        else
            showmsg "You have disabled the option to fetch the sets."
            bye 1
        fi

        [ -n "$verbose_mode" ] && echo "=> NEXT STEP: ${progname} base"

        ;;
    base)
        for F in ${BASE_SETS}
        do
            if [ ! -f $BASE_SETS_DIR/$F ]; then
                showmsg "Cannot find $F, exiting."
		bye 1
            fi
	done

	showmsg "Installing base sets:"
	for S in ${BASE_SETS}
	do
	    if [ -f $BASE_SETS_DIR/$S ]; then
	        echo -n "=> Unpacking $S..."
		@TAR@ xfzp $BASE_SETS_DIR/$S -C $ISODIR
		showmsgstring
	    fi
	done

        if is_enabled ENABLE_X11; then
	    for FX in ${X11_SETS}
	    do
	        if [ ! -f $X11_SETS_DIR/$FX ]; then
                    showmsg "Can't find $FX, disabling X11."
		    DISABLE_X11=yes
		    break
		fi
            done
	    if [ "$DISABLE_X11" = "" ]; then
		showmsg "Installing X11 sets:"
		for X in ${X11_SETS}
		do
		    if [ -f $X11_SETS_DIR/$X ]; then
		        echo -n "=> Unpacking $X..."
			@TAR@ xfzp $X11_SETS_DIR/$X -C $ISODIR
			showmsgstring
                    fi
		done
            fi
	fi # ENABLE_X11
			
	cp $SHAREDIR/livecd $ISODIR/etc/rc.d

	# /etc/rc.conf
	showmsg_n "Installing configuration files..."
	sed -e "s,rc_configured=NO,rc_configured=YES,g" \
	    $ISODIR/etc/rc.conf > $ISODIR/etc/rc.conf.fixed
	mv $ISODIR/etc/rc.conf.fixed $ISODIR/etc/rc.conf
	touch $ISODIR/etc/fstab

	(						    \
	echo "livecd=yes";				    \
	echo "dhclient=no";                                 \
	echo "wscons=yes";				    \
	echo "hostname=$HOSTNAME";			    \
	echo "nfs_client=yes";				    \
	echo "inetd=no";				    \
	echo "ntpdate=no";				    \
	echo "savecore=no";				    \
	echo "ldconfig=no";				    \
	echo "clear_tmp=no";				    \
	) >> $ISODIR/etc/rc.conf

	# /etc/rc.d/root could umount the ramfs directories, 
	# so it's best not to touch them.

	rm $ISODIR/etc/rc.d/root
	cat > $ISODIR/etc/rc.d/root <<_EOF_
#!/bin/sh
#
# \$NetBSD: mklivecd.sh,v 1.35 2007/04/10 20:52:01 xtraeme Exp $
# 

# PROVIDE: root
# REQUIRE: fsck

. /etc/rc.subr

name="root"
start_cmd="root_start"
stop_cmd=":"

root_start()
{
        rm -f /fastboot
}

load_rc_config \$name
run_rc_command "\$1"
_EOF_
	showmsgstring
	# Make sure the devices are created before creating
	# the .tgz files.

	showmsg_n "Creating devices..."
	cd $ISODIR/dev && ./MAKEDEV all
	showmsgstring
	showmsg "Target base finished."
	[ -n "$verbose_mode" ] && \
	    echo "=> NEXT STEP: ${progname} chroot"
    ;;
    chroot)
        if [ ! -f $ISODIR/etc/profile ]; then 
            (					\
	    echo "export PS1=\"$KERNEL_NAME> \"";	\
	    echo "set -o emacs";			\
	    ) > $ISODIR/etc/profile
	else
	    [ -n "$verbose_mode" ] && \
	        showmsg "Not overwriting /etc/profile."
	fi

	[ ! -d $ISODIR/usr/pkgsrc/distfiles ] && \
	    mkdir -p $ISODIR/usr/pkgsrc/distfiles

        [ ! -d $ISODIR/usr/pkgsrc/packages ] && \
            mkdir -p $ISODIR/usr/pkgsrc/packages

	[ ! -f $ISODIR/usr/share/misc/termcap ] && \
	    cp /usr/share/misc/termcap* $ISODIR/usr/share/misc

	showmsg "Entering into the chroot!"

	if [ -d $PKGSRCDIR ]; then
	    if [ -f $pkgsrc_mntstat ]; then
	        count=$(cat $pkgsrc_mntstat)
		count=$(($count + 1))
		echo $count > $pkgsrc_mntstat
		echo "=> pkgsrc directory already mounted."
            else
                mount_null $PKGSRCDIR $ISODIR/usr/pkgsrc
                if [ "$?" -eq 0 ]; then
		    echo "=> pkgsrc directory ready."
		    echo "1" > $pkgsrc_mntstat
                fi
            fi
	else
	    	showmsg "==> CANNOT FIND $PKGSRCDIR"
	fi
		
	if [ -d $PKGSRCDISTDIR ]; then
	    if [ -f $pkgsrcdist_mntstat ]; then
		count=$(cat $pkgsrcdist_mntstat)
		count=$(($count +1))
		echo $count > $pkgsrcdist_mntstat
		echo "=> distfiles directory already mounted."
	    else
                mount_null $PKGSRCDISTDIR $ISODIR/usr/pkgsrc/distfiles
                if [ "$?" -eq 0 ]; then
		    echo "=> distfiles directory ready."
		    echo "1" > $pkgsrcdist_mntstat
                fi
            fi
	else
	    echo "==> CANNOT FIND $PKGSRCDISTDIR"
	fi

        if [ -d $PACKAGESDIR ]; then
            if [ -f $packages_mntstat ]; then
                count=$(cat $packages_mntstat)
                count=$(($count + 1))
                echo $count > $packages_mntstat
                echo "=> packages directory already mounted."
            else
                mount_null $PACKAGESDIR $ISODIR/usr/pkgsrc/packages
                if [ "$?" -eq 0 ]; then
                    echo "=> packages directory ready."
                    echo "1" > $packages_mntstat
                fi
            fi
        else
            echo "==> CANNOT FIND $PACKAGESDIR"
        fi

	echo
	chroot $ISODIR $CHROOT_SHELL
	echo

	if [ ! -d $ISODIR/root ]; then
	    showmsg "Cannot find root directory, exiting."
	    bye 1
	fi

	cd $ISODIR
	cp -f $SHAREDIR/livecd $ISODIR/etc/rc.d

        mkdir -p $ISODIR/ramfs

        SUBST_H_MKDIR="/rescue/mkdir -p /ramfs/home"
	SUBST_H_MNT="/rescue/mount_null /ramfs/home /home"
	SUBST_H_UNPACK="/rescue/tar xfzp /stand/ramfs_home.tgz -C /"
        SUBST_S_MKDIR="/rescue/mkdir -p /ramfs/pkg_sysconfdir"
	SUBST_S_MNT="/rescue/mount_null /ramfs/pkg_sysconfdir /usr/pkg/etc" 
	SUBST_S_UNPACK="/rescue/tar xfzp /stand/ramfs_pkg_sysconfdir.tgz -C /"

	sed -e "s|@MNT_RAMFS_ARGS@|$MNT_RAMFS_ARGS|g" \
            -e "s|@MNT_RAMFS_CMD@|$MNT_RAMFS_CMD|g" \
	    $ISODIR/etc/rc.d/livecd > $ISODIR/etc/rc.d/livecd.in
	mv $ISODIR/etc/rc.d/livecd.in $ISODIR/etc/rc.d/livecd
		
	for U in root dev etc home
	do
	    if [ -d $ISODIR/$U ]; then
	        showmsg_n "Creating /stand/ramfs_$U.tgz... "
		@TAR@ cfzp $ISODIR/stand/ramfs_$U.tgz $U >/dev/null 2>&1
		showmsgstring
            fi
	done

        if is_disabled VND_COMPRESSION; then
                showmsg_n "Creating /stand/ramfs_var.tgz... "
                @TAR@ cfzp $ISODIR/stand/ramfs_var.tgz var >/dev/null 2>&1
                showmsgstring
        fi
 
	if [ -d $ISODIR/home ]; then
	    sed	-e "s|@HOME_MKDIR@|$SUBST_H_MKDIR|" \
                -e "s|@HOME_MOUNT@|$SUBST_H_MNT|" \
                -e "s|@HOME_UNPACK@|$SUBST_H_UNPACK|" \
		$ISODIR/etc/rc.d/livecd > $ISODIR/etc/rc.d/livecd.f
	    mv $ISODIR/etc/rc.d/livecd.f $ISODIR/etc/rc.d/livecd
	else
	    sed	-e "s|@HOME_MKDIR@||" \
                -e "s|@HOME_MOUNT@||" \
                -e "s|@HOME_UNPACK@||" \
                $ISODIR/etc/rc.d/livecd > $ISODIR/etc/rc.d/livecd.f
            mv $ISODIR/etc/rc.d/livecd.f $ISODIR/etc/rc.d/livecd
	fi
                        
	if [ -d $ISODIR/$PKG_SYSCONFDIR ]; then
	    showmsg_n "Creating /stand/ramfs_pkg_sysconfdir.tgz..."
	    @TAR@ cfzp $ISODIR/stand/ramfs_pkg_sysconfdir.tgz \
		$PKG_SYSCONFDIR >/dev/null 2>&1
	    showmsgstring
	    sed	-e "s|@USRPKGETC_MKDIR@|$SUBST_S_MKDIR|" \
                -e "s|@USRPKGETC_MOUNT@|$SUBST_S_MNT|" \
                -e "s|@USRPKGETC_UNPACK@|$SUBST_S_UNPACK|" \
		$ISODIR/etc/rc.d/livecd > $ISODIR/etc/rc.d/livecd.f
             mv $ISODIR/etc/rc.d/livecd.f $ISODIR/etc/rc.d/livecd
	else
	    sed -e "s|@USRPKGETC_MKDIR@||" \
                -e "s|@USRPKGETC_MOUNT@||" \
                -e "s|@USRPKGETC_UNPACK@||" \
	        $ISODIR/etc/rc.d/livecd > $ISODIR/etc/rc.d/livecd.f
            mv $ISODIR/etc/rc.d/livecd.f $ISODIR/etc/rc.d/livecd
	fi

        if is_enabled ENABLE_X11 && [ ! -f $ISODIR/etc/X11/XF86Config ]; then
            if [ -f /etc/X11/XF86Config ]; then
                cp /etc/X11/XF86Config $ISODIR/etc/X11
            fi
        fi
 
	if is_enabled PERSONAL_CONFIG; then
            if [ -f $config_dir/$pers_conffile ]; then
	        echo
	    	showmsg_n "Running personal config file..."
	    	. $config_dir/$pers_conffile
		showmsgstring
	    	echo
            else
		echo
		echo "==> CANNOT FIND PERSONAL CONFIGURATION FILE"
		echo
                bye 1
            fi
        fi
		
        # Make sure livecd has the right permissions, because
	# it could be critical!.

	chmod -R a+rx $ISODIR/etc/rc.d

        #
        # Unmount pkgsrc related directories.
        #
	if [ ! -f $pkgsrcdist_mntstat ]; then
	    showmsg "distfiles directory was not mounted."
	else
	    cnt=$(cat $pkgsrcdist_mntstat)
	    if [ "$cnt" -gt 1 ]; then
                cnt=$(($cnt - 1))
		echo $cnt > $pkgsrcdist_mntstat
		[ -n "$verbose_mode" ] && \
		    echo "=> distfiles directory still in use by mklivecd."
            else
                [ -n "$verbose_mode" ] && \
		    echo "=> Unmounting distfiles directory."
		umount -R $ISODIR/usr/pkgsrc/distfiles
		if [ $? -eq 0 ]; then
		    rm $pkgsrcdist_mntstat
		else
		    echo "Can't umount $PKGSRCDISTDIR."
		fi
            fi
	fi

        if [ ! -f $packages_mntstat ]; then
            showmsg "packages directory was not mounted."
        else
            cnt=$(cat $packages_mntstat)
            if [ "$cnt" -gt 1 ]; then
                cnt=$(($cnt - 1))
                echo $cnt > $packages_mntstat
                echo "=>pkgsrc directory still in use by mklivecd."
            else
                [ -n "$verbose_mode" ] && \
                    echo "=> Unmounting packages directory."
                umount -R $ISODIR/usr/pkgsrc/packages
                if [ "$?" -eq 0 ]; then
                    rm $packages_mntstat
                else
                    echo "Can't umount $PACKAGESDIR."
                fi
            fi
        fi

	if [ ! -f $pkgsrc_mntstat ]; then
	    showmsg "pkgsrc directory was not mounted."
	else
	    cnt=$(cat $pkgsrc_mntstat)
	    if [ "$cnt" -gt 1 ]; then
	        cnt=$(($cnt - 1)) 
		echo $cnt > $pkgsrc_mntstat 
		echo "=> pkgsrc directory still in use by mklivecd."
	    else
		[ -n "$verbose_mode" ] && \
	    	    echo "=> Unmounting pkgsrc directory."
		umount -R $ISODIR/usr/pkgsrc
		if [ $? -eq 0 ]; then
		    rm $pkgsrc_mntstat
		else
		    echo "Can't umount $PKGSRCDIR."
		fi
            fi
	fi

	[ -n "$verbose_mode" ] && showmsg "Size: $(du -sh $ISODIR)"
    ;;
    clean)
        if [ -f $pkgsrc_mntstat -o -f $pkgsrcdist_mntstat -o -f $packages_mntstat ]; then
            showmsg "The pkgsrc directories are still in use! Exiting."
            bye 1
	fi
	showmsg "Cleaning WORKDIR: $WORKDIR"
	rm -rf $WORKDIR
	for F in bin dev etc lib libexec mnt rescue root tmp usr var sbin home
	do
            if [ -d $ISODIR/$F ]; then
	        showmsg_n "Removing $ISODIR/$F..."
		rm -rf $ISODIR/$F
		showmsgstring
            fi
	done
    ;;
    iso)
        if is_enabled VND_COMPRESSION; then
            cd $ISODIR

            if [ ! -f $ISODIR/stand/usr.zfs ]; then
                showmsg_n "Creating image of /usr... "
                makefs -t ffs stand/usr.fs usr > /dev/null 2>&1
                showmsgstring
                showmsg_n "Compressing image of /usr... "
                vndcompress stand/usr.fs stand/usr.zfs > /dev/null 2>&1
                showmsgstring
                rm stand/usr.fs
                showmsg_n "Removing /usr... "
                rm -rf $ISODIR/usr/*
                showmsgstring
            fi
            if [ -d $ISODIR/var/db/pkg ]; then
                if [ ! -f stand/var_db_pkg.zfs ]; then
                    showmsg_n "Creating image of /var/db/pkg... "
                    makefs -t ffs -M 1m $ISODIR/stand/var_db_pkg.fs \
                        var/db/pkg > /dev/null 2>&1
                    showmsgstring
                    showmsg_n "Compressing image of /var/db/pkg... "
                    vndcompress $ISODIR/stand/var_db_pkg.fs \
                        $ISODIR/stand/var_db_pkg.zfs > /dev/null 2>&1
                    showmsgstring
                    rm -f $ISODIR/stand/var_db_pkg.fs
                    showmsg_n "Removing /var/db/pkg... "
                    rm -rf $ISODIR/var/db/pkg/*
                    showmsgstring
                    @TAR@ cfzp stand/ramfs_var.tgz var
                fi
            else
                    @TAR@ cfzp stand/ramfs_var.tgz var
            fi
        fi

        #
        # Detect if we are running a MULTIBOOT kernel.
        #
        if [ -f $ISODIR/$GRUB_BOOTDIR/menu.lst -a -f $WORKDIR/$KERNEL_CONFIG ]; then
            gunzip $ISODIR/$GRUB_BOOTDIR/$KERNEL_CONFIG
            config -x $ISODIR/$GRUB_BOOTDIR/$KERNEL_CONFIG | grep -q MULTIBOOT
            if [ "$?" -eq 0 ]; then
                showmsg "Applying fix for MULTIBOOT kernel..."
                sed -e "s|\--type=netbsd||g" $ISODIR/boot/grub/menu.lst > \
                    $ISODIR/boot/grub/menu.lst.in
                mv $ISODIR/boot/grub/menu.lst.in $ISODIR/boot/grub/menu.lst
            fi
            gzip -9 $ISODIR/$GRUB_BOOTDIR/$KERNEL_CONFIG
        fi

        _do_real_iso_image()
        {
            if [ -f "$BASEDIR/$IMAGE_NAME.iso" ]; then
                [ -n "$verbose_mode" ] && \
                    echo "=> Removing $IMAGE_NAME.iso..."
                rm $BASEDIR/$IMAGE_NAME.iso
            fi

            if [ ! -f $ISODIR/stand/ramfs_etc.tgz ]; then
                showmsg "Cannot find ramfs_etc.tgz file."
		bye 1
            fi
            for RM in ${REMOVE_DIRS}
            do
                if [ -d $ISODIR/$RM ]; then
                    echo -n "=> Removing $RM..."
		    rm -rf $ISODIR/$RM
		    showmsgstring
		fi
            done

            sleep 2 # Because I want to see the messages :-)

            showmsg_n "Creating ISO CD9660 image..."
            if is_enabled USE_GNU_GRUB; then
                [ -d $ISODIR/$GRUB_BOOTDIR ] && \
                    chown -R root:wheel $ISODIR/$GRUB_BOOTDIR
                $MKISOFS_BIN $MKISOFS_FIXED_ARGS $GRUB_BOOT_ARGS $MKISOFS_ARGS \
		-b $GRUB_BOOTDIR/$GRUB_BOOTIMAGE \
		-o $BASEDIR/$IMAGE_NAME.iso $ISODIR > /dev/null 2>&1
		showmsgstring
            else
		$MKISOFS_BIN $MKISOFS_FIXED_ARGS $MKISOFS_ARGS \
		    -b ${CDBOOT_IMG} -o $BASEDIR/$IMAGE_NAME.iso $ISODIR \
                    > /dev/null 2>&1
		showmsgstring
            fi
	}
	if [ -f $BASEDIR/$IMAGE_NAME.iso ]; then
	    echo "* Found $IMAGE_NAME.iso."
	    echo -n "=> Do you want to overwrite this image? (y/n) "
	    read output_u
            if [ "$output_u" = "y" ]; then
                _do_real_iso_image
            elif [ "$output_u" = "n" -o "$output_u" != "y" ]; then
		showmsg "Exiting."
            fi
        else
            _do_real_iso_image
	fi
    ;;
    burn)
        if [ ! -f $BASEDIR/$IMAGE_NAME.iso ]; then
            showmsg "Can't find iso image!, exiting."
            bye 1
	fi

        [ is_enabled BLANK_BEFORE_BURN ] && \
	    $CDRECORD_BIN dev=$CDROM_DEVICE $CDRECORD_ARGS blank=fast
		
	$CDRECORD_BIN dev=$CDROM_DEVICE $CDRECORD_ARGS $BASEDIR/$IMAGE_NAME.iso
    ;;
    esac
	
}

checkconf()
{
    if [ -f $config_file ]; then
        if [ $(id -u) -ne 0 ]; then
            showmsg "MUST BE RUN AS ROOT!" 
            bye 1
        fi
        do_conf_reset; do_conf
    else
        showmsg "$config_file DOESN'T EXIST, EXITING!"
        bye 1
    fi
}

# =========================================================================== #
#  Main program								      #
# =========================================================================== #

args=$(getopt c:k:v $*)
if [ $? -ne 0 ]; then
    usage
fi
set -- $args
while [ $# -gt 0 ]; do
    case "$1" in
    -c)
        config_file="$config_dir/$2"
	shift
	;;
    -k)
        kernel_arg="$2"
        K_ARG_SET=1
        shift
        ;;
    -v)
	verbose_mode=on
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

if [ -z "$config_file" ]; then
    config_file=$config_dir/mklivecd.conf
fi

if [ -z "$verbose_mode" ]; then
    verbose_mode=
fi

target=$1

case "$target" in
    iso)
        checkconf
        do_cdlive iso
    ;;
    kernel)
        do_cdlive kernel
    ;;
    base)
        checkconf
        do_cdlive base
    ;;
    chroot)
        checkconf
        do_cdlive chroot
    ;;
    clean)
        checkconf
        do_cdlive clean
    ;;
    config)
        do_conf
    ;;
    burn)
        checkconf
        do_cdlive burn
    ;;
    fetch)
        do_cdlive fetch
    ;;
    *)
        usage
    ;;
esac

exit 0 # agur! (that's all folks)

# vim: expandtab:softtabstop=4:shiftwidth=4
