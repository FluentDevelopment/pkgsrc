#!@PERL@ -w
#
# pkglint - lint for package directory
#
# implemented by:
#	Jun-ichiro itojun Hagino <itojun@itojun.org>
#	Yoshishige Arai <ryo2@on.rim.or.jp>
#
# Copyright(c) 1997 by Jun-ichiro Hagino <itojun@itojun.org>.
# All rights reserved.
# Freely redistributable.  Absolutely no warranty.
#
# From Id: portlint.pl,v 1.64 1998/02/28 02:34:05 itojun Exp
# $NetBSD: pkglint.pl,v 1.120 2004/10/15 12:14:14 wiz Exp $
#
# This version contains lots of changes necessary for NetBSD packages
# done by Hubert Feyrer <hubertf@netbsd.org>,
# Thorsten Frueauf <frueauf@netbsd.org>, Thomas Klausner <wiz@netbsd.org>,
# Roland Illig <roland.illig@gmx.de> and others.
#

#==========================================================================
# Some comments on the overall structure: The @EXPORT clauses in the pack-
# ages must be in a BEGIN block, because otherwise the names starting with
# an uppercase letter are not recognized as subroutines but as file handles.
#==========================================================================

package PkgLint::Utils;
#==========================================================================
# This package is a catch-all for everything that does not fit in any other
# package. Currently it contains the boolean constants C<false> and C<true>.
#==========================================================================
BEGIN {
	use Exporter;
	use vars qw(@ISA @EXPORT_OK);
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(false true);
}

use constant false	=> 0;
use constant true	=> 1;

#== End of PkgLint::Utils =================================================

package PkgLint::Logging;
#==========================================================================
# This package provides the subroutines log_error, log_warning and log_info
# for printing messages to the user in a common format. The three subrou-
# tines have the parameters $file, $lineno and $message. In case there's no
# file appropriate for the message, NO_FILE may be passed, likewise for
# $lineno and NO_LINE_NUMBER. At the end of the program, the subroutine
# print_summary_and_exit should be called.
#
# Examples:
#   log_error(NO_FILE, NO_LINE_NUMBER, "invalid command line.");
#   log_warning($file, NO_LINE_NUMBER, "not found.");
#   log_info($file, $lineno, sprintf("invalid character (0x%02x).", $c));
#==========================================================================

use strict;
use warnings;
BEGIN {
	use Exporter;
	use vars qw(@ISA @EXPORT_OK);
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(
		NO_FILE NO_LINE_NUMBER
		log_error log_warning log_info
		print_summary_and_exit set_verbose is_verbose
	);
	import PkgLint::Utils qw(false true);
}

use constant NO_FILE		=> "";
use constant NO_LINE_NUMBER	=> 0;

my $errors		= 0;
my $warnings		= 0;
my $verbose_flag	= false;

sub log_message($$$$)
{
	my ($file, $lineno, $type, $message) = @_;
	if ($file ne NO_FILE) {
		$file =~ s,^(?:\./)+,,;
	}
	if ($file eq NO_FILE) {
		printf("%s: %s\n", $type, $message);
	} elsif ($lineno == NO_LINE_NUMBER) {
		printf("%s: %s: %s\n", $type, $file, $message);
	} else {
		printf("%s: %s:%d: %s\n", $type, $file, $lineno, $message);
	}
}

sub log_error($$$)
{
	my ($file, $lineno, $msg) = @_;
	log_message($file, $lineno, "FATAL", $msg);
	$errors++;
}

sub log_warning($$$)
{
	my ($file, $lineno, $msg) = @_;
	log_message($file, $lineno, "WARN", $msg);
	$warnings++;
}

sub log_info($$$)
{
	my ($file, $lineno, $msg) = @_;
	if ($verbose_flag) {
		log_message($file, $lineno, "OK", $msg);
	}
}

sub print_summary_and_exit()
{
	if ($errors != 0 || $warnings != 0) {
		print("$errors errors and $warnings warnings found.\n");
	} else {
		print "looks fine.\n";
	}
	exit($errors != 0);
}

sub set_verbose($)
{
	my ($verbose) = @_;
	$verbose_flag = $verbose;
}

sub is_verbose()
{
	return $verbose_flag;
}
#== End of PkgLint::Logging ===============================================

package PkgLint::FileUtils;
#==========================================================================
# This package provides some file handling subroutines. The subroutine
# load_file reads a file into memory as an array of lines. A line is a
# record that contains the fields C<file>, C<lineno> and C<text>.
#==========================================================================

package PkgLint::FileUtils::Line;
	sub new($$$$) {
		my ($class, $file, $lineno, $text) = @_;
		my ($self) = ({});
		bless($self, $class);
		$self->_init($file, $lineno, $text);
		return $self;
	}
	sub _init($$$$) {
		my ($self, $file, $lineno, $text) = @_;
		$self->{"file"} = $file;
		$self->{"lineno"} = $lineno;
		$self->{"text"} = $text;
	}
	sub file($) {
		return shift(@_)->{"file"};
	}
	sub lineno($) {
		return shift(@_)->{"lineno"};
	}
	sub text($) {
		return shift(@_)->{"text"};
	}
	sub toString($) {
		my ($self) = @_;
		return sprintf("%s:%d: %s", $self->file, $self->line, $self->text);
	}
# end of PkgLint::FileUtils::Line

package PkgLint::FileUtils;
BEGIN {
	use Exporter;
	use vars qw(@ISA @EXPORT_OK);
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(load_file);
}

sub load_file($) {
	my ($fname) = @_;
	my ($result, $line, $lineno);

	$result = [];
	open(F, "< $fname") or return undef;
	$lineno = 0;
	while (defined($line = <F>)) {
		$lineno++;
		$line =~ s/\r*\n*\z//;
		push(@$result, PkgLint::FileUtils::Line->new($fname, $lineno, $line));
	}
	close(F) or return undef;
	return $result;
}

#== End of PkgLint::FileUtils =============================================

package main;
#==========================================================================
# This is the main package of pkglint. Currently it contains a lot of
# functionality, but that will be moved into separate packages.
#==========================================================================
use strict;
use warnings;

use Getopt::Long qw(:config no_ignore_case bundling require_order);
use File::Basename;
use FileHandle;
use Cwd;

BEGIN {
	import PkgLint::Utils qw(false true);
	import PkgLint::Logging qw(
		NO_FILE NO_LINE_NUMBER
		log_error log_warning log_info
		print_summary_and_exit
	);
	import PkgLint::FileUtils qw(
		load_file
	);
}

# Buildtime configuration
my $conf_rcsidstr	= 'NetBSD';
my $conf_portsdir	= '@PORTSDIR@';
my $conf_localbase	= '@PREFIX@';
my $conf_distver	= '@DISTVER@';
my $conf_make		= '@MAKE@';

# Command Line Options
my $opt_committer	= true;
my $opt_dumpmakefile	= false;
my $opt_contblank	= 1;
my $opt_packagedir	= ".";
my (%options) = (
	"-p"		=> "warn about use of \$(VAR) instead of \${VAR}",
	"-d"		=> "check items useful for package developers",
	"-I"		=> "dump the Makefile after parsing",
	"-N"		=> "assume a new (still uncommitted) package",
	"-B#"		=> "allow # contiguous blank lines in Makefiles",
	"-C{check,...}"	=> "enable or disable specific checks",
	"-W{warn,...}"	=> "enable or disable specific warnings",
	"-h|--help"	=> "print a detailed help message",
	"-V|--version"	=> "print the version number of pkglint",
	"-v|--verbose"	=> "print progress messages on STDERR",
);

my $opt_check_distinfo	= true;
my $opt_check_extra	= true;
my $opt_check_MESSAGE	= true;
my $opt_check_patches	= true;
my $opt_check_PLIST	= true;
my $opt_check_newpkg	= false;
my (%checks) = (
	"distinfo"	=> [\$opt_check_distinfo, "check distinfo file"],
	"extra"		=> [\$opt_check_extra, "check various additional files"],
	"MESSAGE"	=> [\$opt_check_MESSAGE, "check MESSAGE files"],
	"patches"	=> [\$opt_check_patches, "check patches"],
	"PLIST"		=> [\$opt_check_PLIST, "check PLIST files"],
	"newpkg"	=> [\$opt_check_newpkg, "special checks for uncommitted packages"],
);

my $opt_warn_patches	= true;
my $opt_warn_exec	= true;
my $opt_warn_absname	= true;
my $opt_warn_directcmd	= true;
my $opt_warn_paren	= true;
my (%warnings) = (
	"patches"	=> [\$opt_warn_patches, "warn on non-optimal patch files"],
	"exec"		=> [\$opt_warn_exec, "warn if source files are executable"],
	"absname"	=> [\$opt_warn_absname, "warn about use of absolute file names"],
	"directcmd"	=> [\$opt_warn_directcmd, "warn about use of direct command names instead of Make variables"],
	"paren"		=> [\$opt_warn_paren, "warn about usa of \$(VAR) instead of \${VAR} in Makefiles"],
);

# Constants
my $regex_rcsidstr	= qr"\$($conf_rcsidstr)(?::[^\$]*|)\$";
my $regex_known_rcs_tag	= qr"\$(Author|Date|Header|Id|Locker|Log|Name|RCSfile|Revision|Source|State|$conf_rcsidstr)(?::[^\$]*?|)\$";
my $regex_validchars	= qr"[\011\040-\176]";

# Global variables that should be eliminated by the next refactoring.
my %definesfound	= ();
my $pkgdir		= ".";
my $filesdir		= "files";
my $patchdir		= "patches";
my $distinfo		= "distinfo";
my $scriptdir		= "scripts";
my %cmdnames		= ();
my $seen_PLIST_SRC	= false;
my $seen_NO_PKG_REGISTER= false;
my $seen_NO_CHECKSUM	= false;
my $seen_USE_PKGLOCALEDIR = false;
my $seen_USE_BUILDLINK3 = false;
my %seen_Makefile_include = ();
my %predefined;
my $pkgname		= "";

# these subroutines return C<true> if the checking succeeded (that includes
# errors in the file) and C<false> if the file could not be checked.
sub checkfile_DESCR($);
sub checkfile_distinfo($);
sub checkfile_Makefile($);
sub checkfile_MESSAGE($);
sub checkfile_patches_patch($);
sub checkfile_PLIST($);

sub print_summary_and_exit();
sub checkperms($);
sub checkpathname($);
sub checklastline($);
sub readmakefile($);
sub checkextra($$);
sub checkorder($$@);
sub checkearlier($@);
sub abspathname($$);
sub is_predefined($);
sub category_check();
sub check_package();

sub print_table($$)
{
	my ($out, $table) = @_;
	my (@width) = ();
	foreach my $row (@$table) {
		foreach my $i (0..(scalar(@$row)-1)) {
			if (!defined($width[$i]) || length($row->[$i]) > $width[$i]) {
				$width[$i] = length($row->[$i]);
			}
		}
	}
	foreach my $row (@$table) {
		my ($max) = (scalar(@$row) - 1);
		foreach my $i (0..$max) {
			if ($i != 0) {
				print $out ("  ");
			}
			print $out ($row->[$i]);
			if ($i != $max) {
				print $out (" " x ($width[$i] - length($row->[$i])));
			}
		}
		print $out ("\n");
	}
	return 1;
}

sub help($$$) {
	my ($out, $exitval, $show_all) = @_;
	my ($prog) = (basename($0));
	print $out ("usage: $prog [options] [package_directory]\n\n");

	my (@option_table) = ();
	foreach my $opt (sort keys %options) {
		push(@option_table, ["  ", $opt, $options{$opt}]);
	}
	print $out ("options:\n");
	print_table($out, \@option_table);
	print $out ("\n");

	if (!$show_all) {
		exit($exitval);
	}

	my (@checks_table) = (
		["  ", "all", "", "enable all checks"],
		["  ", "none", "", "disable all checks"],
	);
	foreach my $check (sort keys %checks) {
		push(@checks_table, [ "  ", $check,
			(${$checks{$check}->[0]} ? "(enabled)" : "(disabled)"),
			$checks{$check}->[1]]);
	}
	print $out ("checks: (use \"check\" to enable, \"no-check\" to disable)\n");
	print_table($out, \@checks_table);
	print $out ("\n");

	my (@warnings_table) = (
		["  ", "all", "", "enable all warnings"],
		["  ", "none", "", "disable all warnings"],
	);
	foreach my $warning (sort keys %warnings) {
		push(@warnings_table, [ "  ", $warning,
			(${$warnings{$warning}->[0]} ? "(enabled)" : "(disabled)"),
			$warnings{$warning}->[1]]);
	}
	print $out ("warnings: (use \"warn\" to enable, \"no-warn\" to disable)\n");
	print_table($out, \@warnings_table);
	print $out ("\n");

	exit($exitval);
}

sub parse_multioption($$) {
	my ($value, $optdefs) = @_;
	foreach my $opt (split(qr",", $value)) {
		if ($opt eq "none") {
			foreach my $key (keys %$optdefs) {
				${$optdefs->{$key}->[0]} = false;
			}
		} elsif ($opt eq "all") {
			foreach my $key (keys %$optdefs) {
				${$optdefs->{$key}->[0]} = true;
			}
		} else {
			my ($value) = (($opt =~ s/^no-//) ? false : true);
			if (exists($optdefs->{$opt})) {
				${$optdefs->{$opt}->[0]} = $value;
			} else {
				help(*STDERR, 1, 0);
			}
		}
	}
	return true;
}

sub parse_command_line() {
	my (%options) = (
		"warning|W=s" => sub {
			my ($opt, $val) = @_;
			parse_multioption($val, \%warnings);
		},
		"check|C=s" => sub {
			my ($opt, $val) = @_;
			parse_multioption($val, \%checks);
		},
		"help|h" => sub { help(*STDOUT, 0, 1); },
		"newpackage|N" => \$opt_check_newpkg,
		"verbose|v" => sub { PkgLint::Logging::set_verbose(true); },
		"version|V" => sub { print("$conf_distver\n"); exit(0); },
		"conblank|B=i" => \$opt_contblank,
		"dumpmakefile|I" => \$opt_dumpmakefile,
	);
	{
		local $SIG{__WARN__} = sub {};
		if (!GetOptions(%options)) {
			help(*STDERR, 1, false);
		}
	}
	if (@ARGV) {
		$opt_packagedir = shift(@ARGV);
	}
	return true;
}

sub main() {
	parse_command_line();

	log_info(NO_FILE, NO_LINE_NUMBER, "config: portsdir: \"$conf_portsdir\" ".
		"rcsidstr: \"$conf_rcsidstr\" ".
		"localbase: $conf_localbase");

	if (-f "$opt_packagedir/../Packages.txt") {
		log_info(NO_FILE, NO_LINE_NUMBER, "checking category Makefile.");
		category_check();
	} elsif (-f "$opt_packagedir/../../Packages.txt") {
		check_package();
	} else {
		log_error(NO_FILE, NO_LINE_NUMBER, "cannot check \"$opt_packagedir\".");
	}
	print_summary_and_exit();
}

sub check_package() {
	%predefined = ();
	foreach my $i (split("\n", <<EOF)) {
XCONTRIB	ftp://crl.dec.com/pub/X11/contrib/
XCONTRIB	ftp://ftp.sunsite.auc.dk/pub/X/X.org/contrib/
XCONTRIB	ftp://ftp.uni-paderborn.de/pub/X11/contrib/
XCONTRIB	ftp://ftp.x.org/contrib/
GNU		ftp://ftp.gnu.org/pub/gnu/
GNU		ftp://ftp.wustl.edu/systems/gnu/
GNU		ftp://ftp.informatik.tu-muenchen.de/pub/comp/os/unix/gnu/
PERL_CPAN	ftp://ftp.digital.com/pub/plan/perl/CPAN/modules/by-module/
PERL_CPAN	ftp://ftp.cdrom.com/pub/perl/CPAN/modules/by-module/
TEX_CTAN	ftp://ftp.cdrom.com/pub/tex/ctan/
TEX_CTAN	ftp://ftp.wustl.edu/packages/TeX/
TEX_CTAN	ftp://ftp.funet.fi/pub/TeX/CTAN/
TEX_CTAN	ftp://ftp.tex.ac.uk/public/ctan/tex-archive/
TEX_CTAN	ftp://ftp.dante.de/tex-archive/
SUNSITE		ftp://metalab.unc.edu/pub/Linux/
SUNSITE		ftp://sunsite.unc.edu/pub/Linux/
SUNSITE		ftp://ftp.infomagic.com/pub/mirrors/linux/sunsite/
SUNSITE		ftp://ftp.funet.fi/pub/mirrors/sunsite.unc.edu/pub/Linux/
GNOME		ftp://ftp.gnome.org/pub/GNOME/
GNOME		ftp://ftp.sunet.se/pub/X11/GNOME/
GNOME		ftp://ftp.informatik.uni-bonn.de/pub/os/unix/gnome/
GNOME		ftp://ftp.tuwien.ac.at/hci/gnome.org/GNOME/
SOURCEFORGE	ftp://download.sourceforge.net/
SOURCEFORGE	http://download.sourceforge.net/
EOF
		my ($j, $k) = split(/\t+/, $i);
		$predefined{$k} = $j;
	}

	# we need to handle the Makefile first to get some variables
	log_info(NO_FILE, NO_LINE_NUMBER, "checking Makefile.");
	if (! -f "$opt_packagedir/Makefile") {
		log_error(NO_FILE, NO_LINE_NUMBER, "no Makefile in \"$opt_packagedir\".");
	} else {
		checkfile_Makefile("Makefile") || log_error("$opt_packagedir/Makefile", NO_LINE_NUMBER, "error while reading.");
	}

	#
	# check for files.
	#
	my @checker = ("$pkgdir/DESCR");
	my %checker = ("$pkgdir/DESCR", \&checkfile_DESCR);

	if ($opt_check_MESSAGE) {
		foreach my $msg (<$opt_packagedir/$filesdir/*>, <$opt_packagedir/$pkgdir/*>) {
			if ($msg =~ qr"MESSAGE") {
				push(@checker, $msg);
				$checker{$msg} = \&checkfile_MESSAGE;
			}
		}
	}
	if ($opt_check_PLIST) {
		foreach my $plist (<$opt_packagedir/$filesdir/*>, <$opt_packagedir/$pkgdir/*>) {
			if ($plist =~ qr"PLIST") {
				push(@checker, $plist);
				$checker{$plist} = \&checkfile_PLIST;
			}
		}
	}
	if ($opt_check_patches) {
		foreach my $i (<$opt_packagedir/$patchdir/patch-*>) {
			next if (! -T $i);
			$i =~ s/^\Q$opt_packagedir\E\///;
			next if (defined $checker{$i});
			push(@checker, $i);
			$checker{$i} = \&checkfile_patches_patch;
		}
	}
	if ($opt_check_distinfo) {
		if (-f "$opt_packagedir/$distinfo") {
			my $i = "$distinfo";
			next if (defined $checker{$i});
			push(@checker, $i);
			$checker{$i} = \&checkfile_distinfo;
		}
	}
	if ($opt_check_distinfo && $opt_check_patches) {
		# Make sure there's a distinfo if there are patches
		my $patches = false;
		patch:
	    	    foreach my $i (<$opt_packagedir/$patchdir/patch-*>) {
			if ( -T "$i" ) { 
				$patches = true;
				last patch;
			}
		}
		if ($patches && ! -f "$opt_packagedir/$distinfo" ) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "no $opt_packagedir/$distinfo file. Please run '$conf_make makepatchsum'.");
		}
	}
	if ($opt_check_extra) {
		foreach my $i ((<$opt_packagedir/$filesdir/*>, <$opt_packagedir/$pkgdir/*>)) {
			next if (! -T $i);
			$i =~ s/^\Q$opt_packagedir\E\///;
			next if ($i =~ qr"(?:distinfo$|Makefile$|PLIST|MESSAGE)");
			next if (defined $checker{$i});

			push(@checker, $i);
			$checker{$i} = \&checkpathname;
		}
	}

	foreach my $i (@checker) {
		log_info(NO_FILE, NO_LINE_NUMBER, "checking $i.");
		if (! -f "$opt_packagedir/$i") {
			log_error(NO_FILE, NO_LINE_NUMBER, "no $i in \"$opt_packagedir\".");
		} else {
			$checker{$i}->($i) || log_warning(NO_FILE, NO_LINE_NUMBER, "Cannot open the file $i\n");
			if ($i !~ /patches\/patch/) {
				&checklastline($i) ||
					log_warning(NO_FILE, NO_LINE_NUMBER, "Cannot open the file $i\n");
			}
		}
	}
	if (-f "$opt_packagedir/$distinfo") {
		if ( $seen_NO_CHECKSUM ) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "NO_CHECKSUM set, but $opt_packagedir/$distinfo exists. Please remove it.");
		}
	} else {
		if ( ! $seen_NO_CHECKSUM ) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "no $opt_packagedir/$distinfo file. Please run '$conf_make makesum'.");
		}
	}
	if (-f "$opt_packagedir/$filesdir/md5") {
		log_error(NO_FILE, NO_LINE_NUMBER, "$filesdir/md5 is deprecated -- run '$conf_make mdi' to generate distinfo.");
	}
	if (-f "$opt_packagedir/$filesdir/patch-sum") {
		log_error(NO_FILE, NO_LINE_NUMBER, "$filesdir/patch-sum is deprecated -- run '$conf_make mps' to generate distinfo.");
	}
	if (-f "$pkgdir/COMMENT") {
		log_error(NO_FILE, NO_LINE_NUMBER, "$pkgdir/COMMENT is deprecated -- please use a COMMENT variable instead.");
	}
	if (-d "$opt_packagedir/pkg") {
		log_error(NO_FILE, NO_LINE_NUMBER, "$opt_packagedir/pkg and its contents are deprecated!\n".
			"\tPlease 'mv $opt_packagedir/pkg/* $opt_packagedir' and 'rmdir $opt_packagedir/pkg'.");
	}
	if (-d "$opt_packagedir/scripts") {
		log_warning(NO_FILE, NO_LINE_NUMBER, "$opt_packagedir/scripts and its contents are deprecated! Please call the script(s)\n".
			"\texplicitly from the corresponding target(s) in the pkg's Makefile.");
	}
	if (! -f "$opt_packagedir/$pkgdir/PLIST"
	    and ! -f "$opt_packagedir/$pkgdir/PLIST-mi"
	    and ! $seen_PLIST_SRC
	    and ! $seen_NO_PKG_REGISTER ) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "no PLIST or PLIST-mi, and PLIST_SRC and NO_PKG_REGISTER unset.\n     Are you sure PLIST handling is ok?");
	}
	if ($opt_committer) {
		if (scalar(@_ = <$opt_packagedir/work*/*>) || -d "$opt_packagedir/work*") {
			log_warning(NO_FILE, NO_LINE_NUMBER, "be sure to cleanup $opt_packagedir/work* ".
				"before committing the package.");
		}
		if (scalar(@_ = <$opt_packagedir/*/*~>) || scalar(@_ = <$opt_packagedir/*~>)) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "for safety, be sure to cleanup ".
				"emacs backup files before committing the package.");
		}
		if (scalar(@_ = <$opt_packagedir/*/*.orig>) || scalar(@_ = <$opt_packagedir/*.orig>)
		 || scalar(@_ = <$opt_packagedir/*/*.rej>) || scalar(@_ = <$opt_packagedir/*.rej>)) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "for safety, be sure to cleanup ".
				"patch backup files before committing the package.");
		}
	}
	return true;
} # check_package

#
# Subroutines common to all checking routines
#

sub checkline_length($$) {
	my ($line, $maxlength) = @_;

	if (length($line->text) > $maxlength) {
		log_warning($line->file, $line->lineno, "Line too long (should be no more than $maxlength characters).");
	}
	return true;
}

sub checkline_valid_characters($$) {
	my ($line, $re_validchars) = @_;
	my ($rest);

	($rest = $line->text) =~ s/$re_validchars//g;
	if ($rest ne "") {
		my @chars = map { $_ = sprintf("0x%02x", ord($_)); } split(//, $rest);
		log_warning($line->file, $line->lineno,
			sprintf("Line contains invalid characters (%s).", join(", ", @chars)));
	}
	return true;
}

sub checkline_trailing_whitespace($) {
	my ($line) = @_;
	if ($line =~ /\s+$/) {
		log_warning($line->file, $line->lineno, "Trailing white space.");
	}
	return true;
}

#
# Specific subroutines
#

sub checkfile_DESCR($) {
	my ($file) = @_;
	my ($maxchars, $maxlines, $fname) = (80, 24, "$opt_packagedir/$file");
	my ($descr);

	checkperms($fname);
	if (!defined($descr = load_file($fname))) {
		log_error($fname, NO_LINE_NUMBER, "Error while reading.");
		return false;
	}

	foreach my $line (@$descr) {
		checkline_length($line, $maxchars);
		checkline_trailing_whitespace($line);
		checkline_valid_characters($line, $regex_validchars);
	}

	if (scalar(@$descr) > $maxlines) {
		log_warning($fname, NO_LINE_NUMBER, "File too long (should be no more than $maxlines lines).");
	}

	return true;
}

sub checkfile_distinfo($) {
	my ($file) = @_;
	my ($fname) = ("$opt_packagedir/$file");
	my ($distinfo, %in_distinfo);

	checkperms($fname);
	if (!defined($distinfo = load_file($fname))) {
		log_error($fname, NO_LINE_NUMBER, "Error while reading.");
		return false;
	}

	if (scalar(@$distinfo) == 0) {
		log_error($fname, NO_LINE_NUMBER, "May not be empty.");
		return true;
	}

	if ($distinfo->[0]->text !~ /^$regex_rcsidstr$/) {
		log_error($fname, 1, "\$$conf_rcsidstr\$ (and nothing more) expected.");
	}

	foreach my $line (@$distinfo[1 .. scalar(@$distinfo)-1]) {
		next unless $line->text =~ /^(MD5|SHA1|RMD160) \(([^)]+)\) = (.*)$/;
		my ($alg, $patch, $sum) = ($1, $2, $3);

		if ($patch =~ /~$/) {
			log_warning($line->file, $line->lineno, "possible backup file \"$patch\"?");
		}

		if ($patch =~ /^patch-[A-Za-z0-9_]+$/) {
			if (-f "$opt_packagedir/$patchdir/$patch") {
				my $chksum = `sed -e '/\$NetBSD.*/d' $opt_packagedir/$patchdir/$patch | digest $alg`;
				$chksum =~ s/\r*\n*\z//;
				if ($sum ne $chksum) {
					log_error($line->file, $line->lineno, "checksum of $patch differs. Rerun '$conf_make makepatchsum'.");
				}
			} else {
				log_error($line->file, $line->lineno, "$patch does not exist.");
			}
			$in_distinfo{$patch} = true;
		}
	}

	foreach my $patch (<$opt_packagedir/$patchdir/patch-*>) {
		$patch = basename($patch);
		if (!exists($in_distinfo{$patch})) {
			log_error($fname, NO_LINE_NUMBER, "$patch is not recorded. Rerun '$conf_make makepatchsum'.");
		}
	}
	return true;
}

sub checkfile_MESSAGE($) {
	my ($file) = @_;
	my ($fname) = ("$opt_packagedir/$file");
	my ($message);

	checkperms($fname);
	if (!defined($message = load_file($fname))) {
		log_error($fname, NO_LINE_NUMBER, "error while reading.");
		return false;
	}

	if (scalar(@$message) < 3) {
		log_warning($fname, NO_LINE_NUMBER, "file too short.");
		return true;
	}
	if ($message->[0]->text ne "=" x 75) {
		log_warning($message->[0]->file, $message->[0]->lineno, "expected a line of exactly 75 \"=\" characters.");
	}
	if ($message->[1]->text !~ /^$regex_rcsidstr$/) {
		log_error($message->[1]->file, $message->[1]->lineno, "expected the RCS Id tag.");
	}
	foreach my $line (@$message[2 .. scalar(@$message) - 2]) {
		checkline_length($line, 80);
		checkline_trailing_whitespace($line);
		checkline_valid_characters($line, $regex_validchars);
	}
	if ($message->[-1]->text ne "=" x 75) {
		log_warning($message->[-1]->file, $message->[-1]->lineno, "expected a line of exactly 75 \"=\" characters.");
	}
	return true;
}

sub checkfile_PLIST($) {
	my ($file) = @_;
	my ($fname) = ("$opt_packagedir/$file");
	my ($plist, $curdir, $rcsid_seen);
	
	checkperms($fname);
	if (!defined($plist = load_file($fname))) {
		log_error($fname, NO_LINE_NUMBER, "error while reading.");
		return false;
	}

	$curdir = $conf_localbase;
	line:
	foreach my $line (@$plist) {
		checkline_trailing_whitespace($line);

		if ($line->text =~ /<\$ARCH>/) {
			log_warning($line->file, $line->text, "use of <\$ARCH> is deprecated, use \${MACHINE_ARCH} instead.");
		}
		if ($line->text =~ /^\@([a-z]+)\s+(.*)/) {
			my ($cmd, $arg) = ($1, $2);
			if ($cmd eq "cwd" || $cmd eq "cd") {
				$curdir = $arg;
			} elsif ($cmd eq "unexec" && $arg =~ /^rmdir/) {
				log_warning($line->file, $line->lineno, "use \"\@dirrm\" instead of \"\@unexec rmdir\".");
			} elsif (($cmd eq "exec" || $cmd eq "unexec")) {
				if ($arg =~ /(?:install-info|\$\{INSTALL_INFO\})/) {
					log_warning($line->file, $line->lineno, "\@exec/unexec install-info is deprecated.");
				} elsif ($arg =~ /ldconfig/ && $arg !~ qr"/usr/bin/true") {
					log_error($line->file, $line->lineno, "ldconfig must be used with \"||/usr/bin/true\".");
				}
			} elsif ($cmd eq "comment") {
				if ($arg =~ /^$regex_rcsidstr$/) {
					$rcsid_seen = true;
				}
			} elsif ($cmd eq "dirrm" || $cmd eq "option") {
				# no check made
			} elsif ($cmd eq "mode" || $cmd eq "owner" || $cmd eq "group") {
				log_warning($line->file, $line->lineno, "\"\@mode/owner/group\" are deprecated, please use chmod/".
					"chown/chgrp in the pkg Makefile and let tar do the rest.");
			} else {
				log_warning($line->file, $line->lineno, "unknown PLIST directive \"\@$cmd\"");
			}
			next line;
		}

		if ($line->text =~ /^\//) {
			log_error($line->file, $line->lineno, "use of full pathname disallowed.");
		}

		if ($line->text =~ /^doc/) {
			log_error($line->file, $line->lineno, "documentation must be installed under share/doc, not doc.");
		}

		if ($line->text =~ /^etc/ && $line->text !~ /^etc\/rc.d/) {
			log_error($line->file, $line->lineno, "configuration files must not be ".
				"registered in the PLIST (don't you use the ".
				"PKG_SYSCONFDIR framework?)");
		}

		if ($line->text =~ /^etc\/rc\.d/) {
			log_error($line->file, $line->lineno, "RCD_SCRIPTS must not be ".
				"registered in the PLIST (don't you use the ".
				"RCD_SCRIPTS framework?)");
		}

		if ($line->text =~ /^info\/dir$/) {
			log_error($line->file, $line->lineno, "\"info/dir\" should not be listed in ".
				"$file. use install-info to add/remove an entry.");
		}

		if ($line->text =~ /^lib\/locale/) {
			log_error($line->file, $line->lineno, "\"lib/locale\" should not be listed ".
				"in $file. Use \${PKGLOCALEDIR}/locale and set USE_PKGLOCALEDIR instead.");
		}

		if ($line->text =~ /^share\/locale/) {
			log_warning($line->file, $line->lineno, "use of \"share/locale\" in $file is ".
				"deprecated.  Use \${PKGLOCALEDIR}/locale and set USE_PKGLOCALEDIR instead.");
		}

		if ($line->text =~ /\${PKGLOCALEDIR}/ && $seen_USE_BUILDLINK3 && !$seen_USE_PKGLOCALEDIR) {
			log_warning($line->file, $line->lineno, "PLIST contains \${PKGLOCALEDIR}, ".
				"but USE_PKGLOCALEDIR was not found.");
		}

		if ($curdir !~ m:^$conf_localbase: && $curdir !~ m:^/usr/X11R6:) {
			log_warning($line->file, $line->lineno, "installing to directory $curdir discouraged. could you please avoid it?");
		}

		if ("$curdir/$line->text" =~ m:^$conf_localbase/share/doc:) {
			log_info($line->file, $line->lineno, "seen installation to share/doc ($curdir/$line).");
		}
	}

	if (!$rcsid_seen) {
		log_error($file, NO_LINE_NUMBER, "Expected a \@comment \"\$$conf_rcsidstr\$\" line.");
	}
	return true;
}

sub checkperms($) {
	my ($file) = @_;

	if ($opt_warn_exec && -f $file && -x $file) {
		log_warning($file, NO_LINE_NUMBER, "should not be executable.");
	}
	return true;
}

#
# misc files
#
sub checkpathname($) {
	my ($file) = @_;
	my ($fname) = ("$opt_packagedir/$file");
	my ($whole);
	
	checkperms($fname);

	if ($file =~ /$filesdir\//) {
		# ignore
		return true;
	}

	# FIXME: convert to load_file.
	open(IN, "< $opt_packagedir/$file") || return false;
	{ local $/; $whole = <IN>; }
	close(IN);
	return abspathname($whole, $file);
}

sub checklastline($) {
	my ($file) = @_;
	my ($fname) = ("$opt_packagedir/$file");
	my ($whole);
	
	if (!open(IN, "< $fname")) {
		log_error($fname, NO_LINE_NUMBER, "could not open: $!");
		return false;
	}
	{ local $/; $whole = <IN>; }
	close(IN);

	if ($whole eq "") {
		log_error($fname, NO_LINE_NUMBER, "file is empty.");
	} elsif ($whole !~ /\n$/) {
		log_error($fname, NO_LINE_NUMBER, "newline expected at end of file.");
	} elsif ($whole =~ /\r*\n(?:[ \t]*\r*\n)+$/) {
		log_warning($fname, NO_LINE_NUMBER, "perhaps unnecessary blank lines at end of file.");
	}
	return true;
}

# $lines => an array of lines as returned by load_file().
sub check_for_multiple_patches($) {
	my ($lines) = @_;
	my ($files_in_patch, $patch_state, $line_type);

	if (!$opt_warn_patches) {
		# all warnings are disabled, so why should we check?
		return;
	}
	$files_in_patch = 0;
	$patch_state = "";
	foreach my $line (@$lines) {
		if (index($line->text, "--- ") == 0 && $line->text !~ qr"^--- \d+(?:,\d+|) ----$") {
			$line_type = "-";
		} elsif (index($line->text, "*** ") == 0 && $line->text !~ qr"^\*\*\* \d+(?:,\d+|) \*\*\*\*$") {
			$line_type = "*";
		} elsif (index($line->text, "+++ ") == 0) {
			$line_type = "+";
		} else {
			$line_type = "";
		}

		if ($patch_state eq "*") {
			if ($line_type eq "-") {
				$files_in_patch++;
				$patch_state = "";
			} else {
				log_warning($line->file, $line->lineno, "unknown patch format (might be an internal error)");
			}
		} elsif ($patch_state eq "-") {
			if ($line_type eq "+") {
				$files_in_patch++;
				$patch_state = "";
			} else {
				log_warning($line->file, $line->lineno, "unknown patch format (might be an internal error)");
			}
		} elsif ($patch_state eq "") {
			$patch_state = $line_type;
		}
	}

	if ($files_in_patch > 1) {
		log_warning($lines->[0]->file, NO_LINE_NUMBER, "contains patches for $files_in_patch files, should be only one");
	} elsif ($files_in_patch == 0) {
		log_warning($lines->[0]->file, NO_LINE_NUMBER, "contains no patch");
	}
	return true;
}

sub checkfile_patches_patch($) {
	my ($file) = @_;
	my ($fname) = "$opt_packagedir/$file";
	my ($lines);

	if ($file =~ /.*~$/) {
		log_warning($fname, NO_LINE_NUMBER, "In case this is a backup file: please remove it and rerun '$conf_make makepatchsum'");
	}

	checkperms($fname);
	if (!defined($lines = load_file($fname))) {
		log_error($fname, NO_LINE_NUMBER, "Could not load file.");
		return false;
	}

	# The first line should contain the RCS Id string
	if (scalar(@$lines) == 0) {
		log_error($fname, NO_LINE_NUMBER, "Empty patch file.");
		return true;
	} elsif ($lines->[0]->text !~ /^$regex_rcsidstr$/) {
		log_error($lines->[0]->file, $lines->[0]->lineno, "Expected RCS tag \"\$$conf_rcsidstr\$\" (and nothing more) here.");
	}

	foreach my $line (@$lines[1..scalar(@$lines)-1]) {
		if ($opt_committer && $line->text =~ /$regex_known_rcs_tag/) {
			log_warning($line->file, $line->lineno, "Possible RCS tag \"\$$1\$\". Use binary mode (-ko) on commit/import.");
		}
	}

	check_for_multiple_patches($lines);
	return true;
}

sub readmakefile($) {
	my ($file) = @_;
	my $contents = "";
	my ($includefile, $dirname, $savedln, $level);
	my $handle = new FileHandle;

	$savedln = $.;
	$. = 0;
	open($handle, "< $file") || return false;
	log_info($file, NO_LINE_NUMBER, "called readmakefile");
	while (defined(my $line = <$handle>)) {
		if ($line =~ /[ \t]+\n?$/ && $line !~ /^#/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "$file $.: whitespace before ".
				"end of line.");
		}
		if ($line =~ /^\040{8}/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "$file $.: use tab (not spaces) to".
				" make indentation.");
		}
		if ($line =~ /^\.\s*if\s+!defined\s*\((\w+)\)/) {
			if ($definesfound{$1}) {
				$level = 1;
				log_info($file, $., "omitting contents of !defined($1)");
				$contents .= "# omitted inclusion for !defined($1) here\n";
				while (defined($line = <$handle>)) {
					if ($line =~ /^\.\s*if\s+/) {
						$level++;
					}
					elsif ($line =~ /^\.\s*endif\s+/) {
						$level--;
					}
					if ($level eq 0) {
						last;
					}
				}
				if ($level > 0) {
					log_warning(NO_FILE, NO_LINE_NUMBER, "missing .endif.");
				}
				next;
			}
			else {
				log_info($file, $., "defining $1");
				$definesfound{$1} = true;
			}
		}
		# try to get any included file
		if ($line =~ /^.include\s+([^\n]+)\n/) {
			$includefile = $1;
			if ($includefile =~ /\"([^\"]+)\"/) {
				$includefile = $1;
			}
			if (exists($seen_Makefile_include{$includefile})) {
				$contents .= "### pkglint ### skipped $includefile\n";
				next;
			}
			$seen_Makefile_include{$includefile} = true;
			if ($includefile =~ /\/mk\/texinfo\.mk/) {
				log_error(NO_FILE, NO_LINE_NUMBER, "do not include $includefile");
			}
			if ($includefile =~ /\/mk\/bsd/) {
				# we don't want to include the whole
				# bsd.pkg.mk or bsd.prefs.mk files
				$contents .= $line;
			} else {
				$dirname = dirname($file);
                                if (-e "$dirname/$includefile") {
                                    log_info($file, $., "including $dirname/$includefile");
                                    $contents .= readmakefile("$dirname/$includefile");
                                }
                                else {
                                    log_error(NO_FILE, NO_LINE_NUMBER, "can't read $dirname/$includefile");
                                }
			}
		} else {
			# we don't want the include Makefile.common lines
			# to be pkglinted
			$contents .= $line;
		}
	}
	close($handle);

	$. = $savedln;
	return $contents;
}

sub checkfile_Makefile($) {
	my ($file) = @_;
	my ($fname) = ("$opt_packagedir/$file");
	my ($tmp, $rawwhole, $whole, $idx, @sections);
	my (@varnames) = ();
	my ($distfiles, $svrpkgname, $distname, $extractsufx) = ('', '', '', '', '');
	my ($bogusdistfiles) = (0);
	my ($realwrksrc, $wrksrc, $nowrksubdir) = ('', '', '');
	my ($includefile);
	my ($category);

	if ($opt_packagedir eq ".") {
		$category = basename(dirname(cwd()));
	} else {
		$category = basename(dirname($opt_packagedir));
	}

	checkperms($fname);

	$tmp = 0;
	$rawwhole = readmakefile($fname);
	if ($rawwhole eq '') {
		log_error(NO_FILE, NO_LINE_NUMBER, "can't read $opt_packagedir/$file");
		return false;
	}
	else {
		print("OK: whole Makefile (with all included files):\n".
		      "$rawwhole\n") if ($opt_dumpmakefile);
	}

	#
	# whole file: blank lines.
	#
	$whole = "\n" . $rawwhole;
	log_info(NO_FILE, NO_LINE_NUMBER, "checking contiguous blank lines in $file.");
	my $i = "\n" x ($opt_contblank + 2);
	if ($whole =~ /$i/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "contiguous blank lines (> $opt_contblank lines) found ".
			"in $file at line " . int(@_ = split(/\n/, $`)) . ".");
	}

	#
	# whole file: $(VARIABLE)
	#
	if ($opt_warn_paren) {
		log_info(NO_FILE, NO_LINE_NUMBER, "checking for \$(VARIABLE).");
		if ($whole =~ /\$\([\w\d]+\)/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "use \${VARIABLE}, instead of ".
				"\$(VARIABLE).");
		}
	}

	#
	# whole file: get FILESDIR, PATCHDIR, PKGDIR, SCRIPTDIR,
	# PATCH_SUM_FILE and DIGEST_FILE
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for PATCHDIR, SCRIPTDIR, FILESDIR, PKGDIR,".
	    " DIGEST_FILE.");

	$filesdir = "files";
	$filesdir = $1 if ($whole =~ /\nFILESDIR[+?]?=[ \t]*([^\n]+)\n/);
	$filesdir = $1 if ($whole =~ /\nFILESDIR:?=[ \t]*([^\n]+)\n/);
	$filesdir =~ s/\$\{.CURDIR\}/./;

	$patchdir = "patches";
	$patchdir = $1 if ($whole =~ /\nPATCHDIR[+?]?=[ \t]*([^\n]+)\n/);
	$patchdir = $1 if ($whole =~ /\nPATCHDIR:?=[ \t]*([^\n]+)\n/);
	$patchdir =~ s/\$\{.CURDIR\}/./;
	$patchdir =~ s/\${PKGSRCDIR}/..\/../;

	$pkgdir = "pkg";
	if (! -d "$opt_packagedir/$pkgdir") {
	    $pkgdir = ".";
	}
	$pkgdir = $1 if ($whole =~ /\nPKGDIR[+?]?=[ \t]*([^\n]+)\n/);
	$pkgdir = $1 if ($whole =~ /\nPKGDIR:?=[ \t]*([^\n]+)\n/);
	$pkgdir =~ s/\$\{.CURDIR\}/./;

	$scriptdir = "scripts";
	$scriptdir = $1 if ($whole =~ /\nSCRIPTDIR[+?]?=[ \t]*([^\n]+)\n/);
	$scriptdir = $1 if ($whole =~ /\nSCRIPTDIR:?=[ \t]*([^\n]+)\n/);
	$scriptdir =~ s/\$\{.CURDIR\}/./;

	$distinfo = "distinfo";
	$distinfo = $1 if ($whole =~ /\nDISTINFO_FILE[+?]?=[ \t]*([^\n]+)\n/);
	$distinfo = $1 if ($whole =~ /\nDISTINFO_FILE:?=[ \t]*([^\n]+)\n/);
	$distinfo =~ s/\$\{.CURDIR\}/./;
	$distinfo =~ s/\${PKGSRCDIR}/..\/../;

	log_info(NO_FILE, NO_LINE_NUMBER, "PATCHDIR: $patchdir, SCRIPTDIR: $scriptdir, ".
	      "FILESDIR: $filesdir, PKGDIR: $pkgdir, ".
	      "DISTINFO: $distinfo\n");

	#
	# whole file: INTERACTIVE_STAGE
	#
	$whole =~ s/\n#[^\n]*/\n/g;
	$whole =~ s/\n\n+/\n/g;
	log_info(NO_FILE, NO_LINE_NUMBER, "checking INTERACTIVE_STAGE.");
	if ($whole =~ /\nINTERACTIVE_STAGE/) {
		if ($whole !~ /defined\((BATCH|FOR_CDROM)\)/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "use of INTERACTIVE_STAGE discouraged. ".
				"provide batch mode by using BATCH and/or ".
				"FOR_CDROM.");
		}
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking USE_BUILDLINK2.");
	if ($whole =~ /\nUSE_BUILDLINK2/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "USE_BUILDLINK2 is deprecated, ".
			"use USE_BUILDLINK3 instead.");
	}
	if ($whole =~ /\nIS_INTERACTIVE/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "IS_INTERACTIVE is deprecated, ".
			"use INTERACTIVE_STAGE instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for PLIST_SRC.");
	if ($whole =~ /\nPLIST_SRC/) {
		$seen_PLIST_SRC = true;
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for NO_PKG_REGISTER.");
	if ($whole =~ /\nNO_PKG_REGISTER/) {
		$seen_NO_PKG_REGISTER = true;
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for NO_CHECKSUM.");
	if ($whole =~ /\nNO_CHECKSUM/) {
		$seen_NO_CHECKSUM = true;
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking USE_PERL usage.");
	if ($whole =~ /\nUSE_PERL[^5]/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "USE_PERL found -- you probably mean USE_PERL5.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking USE_PKGLIBTOOL.");
	if ($whole =~ /\nUSE_PKGLIBTOOL/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "USE_PKGLIBTOOL is deprecated, ".
			"use USE_LIBTOOL instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for USE_BUILDLINK3.");
	if ($whole =~ /\nUSE_BUILDLINK3/) {
		$seen_USE_BUILDLINK3 = true;
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for USE_PKGLOCALEDIR.");
	if ($whole =~ /\nUSE_PKGLOCALEDIR/) {
		$seen_USE_PKGLOCALEDIR = true;
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking USE_SSL.");
	if ($whole =~ /\nUSE_SSL/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "USE_SSL is deprecated, ".
			"use the openssl buildlink3.mk instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking NO_WRKSUBDIR.");
	if ($whole =~ /\nNO_WRKSUBDIR/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "NO_WRKSUBDIR is deprecated, ".
			"use WRKSRC=\$\{WRKDIR\} instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking MD5_FILE, DIGEST_FILE and PATCH_SUM_FILE.");
	if ($whole =~ /\n(MD5_FILE)/ or $whole =~ /\n(DIGEST_FILE)/ or
		$whole =~ /\n(PATCH_SUM_FILE)/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "$1 is deprecated, ".
			"use DISTINFO_FILE instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking MIRROR_DISTFILE.");
	if ($whole =~ /\nMIRROR_DISTFILE/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "use of MIRROR_DISTFILE deprecated, ".
			"use NO_BIN_ON_FTP and/or NO_SRC_ON_FTP instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking NO_CDROM.");
	if ($whole =~ /\nNO_CDROM/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "use of NO_CDROM discouraged, ".
			"use NO_BIN_ON_CDROM and/or NO_SRC_ON_CDROM instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking NO_PACKAGE.");
	if ($whole =~ /\nNO_PACKAGE/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "use of NO_PACKAGE to enforce license ".
			"restrictions is deprecated.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking NO_PATCH.");
	if ($whole =~ /\nNO_PATCH/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "use of NO_PATCH deprecated.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking IGNORE.");
	if ($whole =~ /\nIGNORE/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "use of IGNORE deprecated, ".
			"use PKG_FAIL_REASON or PKG_SKIP_REASON instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking USE_GMAKE.");
	if ($whole =~ /\nUSE_GMAKE/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "use of USE_GMAKE deprecated, ".
			"use USE_GNU_TOOLS+=make instead.");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for MKDIR.");
	if ($whole =~ m|\${MKDIR}.*(\${PREFIX}[/0-9a-zA-Z\${}]*)|) {
	    	log_warning(NO_FILE, NO_LINE_NUMBER, "\${MKDIR} $1: consider using INSTALL_*_DIR");
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for unneeded INSTALL -d.");
	if ($whole =~ m|\${INSTALL}(.*)\n|) {
	    my $args = $1;
	    	if ($args =~ /-d/) {
		        if ($args !~ /-[ogm]/) {
		    		log_warning(NO_FILE, NO_LINE_NUMBER, "\${INSTALL}$args: " .
					"consider using INSTALL_*_DIR");
		        }
		}
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "checking for unneeded failure check on directory creation.");
	if ($whole =~ /\n\t-(.*(MKDIR|INSTALL.*-d|INSTALL_.*_DIR).*)/g) {
	    	log_warning(NO_FILE, NO_LINE_NUMBER, "$1: no need to use '-' before command");
	}

	#
	# whole file: direct use of command names
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking direct use of command names.");
	foreach my $i (split(/\s+/, <<EOF)) {
awk basename cat chmod chown chgrp cmp cp cut digest dirname echo egrep false
file find gmake grep gtar gzcat id ident install ldconfig ln md5 mkdir mtree mv
patch pax pkg_add pkg_create pkg_delete pkg_info rm rmdir sed setenv sh sort
su tail test touch tr true type wc xmkmf
EOF
		$cmdnames{$i} = "\$\{\U$i\E\}";
	}
	$cmdnames{'file'} = '${FILE_CMD}';
	$cmdnames{'gunzip'} = '${GUNZIP_CMD}';
	$cmdnames{'gzip'} = '${GZIP_CMD}';
	#
	# ignore parameter string to echo command.
	# note that we leave the command as is, since we need to check the
	# use of echo itself.
	my $j = $whole;
	$j =~ s/([ \t][\@-]?)(echo|\$[\{\(]ECHO[\}\)]|\$[\{\(]ECHO_MSG[\}\)])[ \t]+("(\\'|\\"|[^"])*"|'(\\'|\\"|[^'])*')[ \t]*[;\n]/$1$2;/;
	# no need to check comments...
	$j =~ s/\n#[\n]*/\n#/;
	# ...nor COMMENTs
	$j =~ s/\nCOMMENT[\t ]*=[\t ]*[^\n]*\n/\nCOMMENT=#replaced\n/;
	if ($opt_warn_directcmd) {
		foreach my $i (keys %cmdnames) {
			if ($j =~ /[ \t\/@]$i[ \t\n;]/) {
				log_warning(NO_FILE, NO_LINE_NUMBER, "possible direct use of command \"$i\" ".
					"found. Use $cmdnames{$i} instead.");
			}
		}
	}

	#
	# whole file: ldconfig must come with "true" command
	#
	if ($j =~ /(ldconfig|\$[{(]LDCONFIG[)}])/
	 && $j !~ /(\/usr\/bin\/true|\$[{(]TRUE[)}])/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "ldconfig must be used with \"||\${TRUE}\".");
	}

	#
	# whole file: ${MKDIR} -p
	#
	if ($j =~ /\${MKDIR}\s+-p/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "possible use of \"\${MKDIR} -p\" ".
			"found. \${MKDIR} includes \"-p\" by default.");
	}
	#
	# whole file: continuation line in DEPENDS
	#
	if ($whole =~ /\n(BUILD_|)DEPENDS[^\n]*\\\n/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "Please don't use continuation lines in".
			" (BUILD_)DEPENDS, use (BUILD_)DEPENDS+= instead.");
	}

	# whole file: check for pkgsrc-wip remnants
	#
	if ($whole =~ /\/wip\//
	 && $category ne "wip") {
		log_error(NO_FILE, NO_LINE_NUMBER, "possible pkgsrc-wip pathname detected.");
	}

	if ($whole =~ /etc\/rc\.d/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "Use RCD_SCRIPTS mechanism to install rc.d ".
			"scripts automatically to \${RCD_SCRIPTS_EXAMPLEDIR}.");
	}

	#
	# whole file: full path name
	#
	&abspathname($whole, $file);

	#
	# break the makefile into sections.
	#
	@sections = split(/\n\n+/, $rawwhole);
	foreach my $i (0..$#sections) {
		if ($sections[$i] !~ /\n$/) {
			$sections[$i] .= "\n";
		}
	}
	$idx = 0;

	#
	# section 1: comment lines.
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking comment section of $file.");
	$tmp = $sections[$idx++];
	if ($tmp !~ /#(\s+)\$$conf_rcsidstr([^\$]*)\$/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "no \$$conf_rcsidstr\$ line in $file comment ".
			"section.");
	} else {
		log_info(NO_FILE, NO_LINE_NUMBER, "\$$conf_rcsidstr\$ seen in $file.");
		if ($1 ne ' ') {
			log_warning(NO_FILE, NO_LINE_NUMBER, "please use single whitespace ".
				"right before \$$conf_rcsidstr\$ tag.");
		}
		if ($2 ne '') {
			if (PkgLint::Logging::is_verbose || $opt_check_newpkg) {	# XXX
				log_warning(NO_FILE, NO_LINE_NUMBER, "".
				    ($opt_check_newpkg ? 'for new package, '
					      : 'is it a new package? if so, ').
				    "make \$$conf_rcsidstr\$ tag in comment ".
				    "section empty, to make CVS happy.");
			}
		}
	}

	#
	# for the rest of the checks, comment lines are not important.
	#
	foreach my $i (0..$#sections) {
		$sections[$i] =~ s/^#[^\n]*//g;
		$sections[$i] =~ s/\n#[^\n]*//g;
		$sections[$i] =~ s/\n\n+/\n/g;
		$sections[$i] =~ s/^\n+//g;
		$sections[$i] =~ s/\\\n/ /g;
	}

	#
	#
	# section 2: DISTNAME/PKGNAME/...
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking first section of $file. (DISTNAME/...)");
	$tmp = $sections[$idx++];

	# check the order of items.
	{ my @tocheck=split(/\s+/, <<EOF);
DISTNAME PKGNAME PKGREVISION SVR4_PKGNAME CATEGORIES MASTER_SITES
DYNAMIC_MASTER_SITES MASTER_SITE_SUBDIR EXTRACT_SUFX DISTFILES
EOF
	push(@tocheck,"ONLY_FOR_ARCHS");
	push(@tocheck,"NO_SRC_ON_FTP");
	push(@tocheck,"NO_BIN_ON_FTP");
        &checkorder('DISTNAME', $tmp, @tocheck);
	}

	# check the items that has to be there.
	$tmp = "\n" . $tmp;
	foreach my $i ('DISTNAME', 'CATEGORIES') {
		if ($tmp !~ /\n$i=/) {
			log_error(NO_FILE, NO_LINE_NUMBER, "$i has to be there.");
		}
		if ($tmp =~ /\n$i(\?=)/) {
			log_error(NO_FILE, NO_LINE_NUMBER, "$i has to be set by \"=\", ".
				"not by \"$1\".");
		}
	}

	# check for pkgsrc-wip remnants in CATEGORIES
	if ($tmp =~ /\nCATEGORIES=[ \t]*.*wip.*\n/
	 && $category ne "wip") {
		log_error(NO_FILE, NO_LINE_NUMBER, "don't forget to remove \"wip\" from CATEGORIES.");
	}

	# check the URL
	if ($tmp =~ /\nMASTER_SITES[+?]?=[ \t]*([^\n]*)\n/
	 && $1 !~ /^[ \t]*$/) {
		log_info(NO_FILE, NO_LINE_NUMBER, "seen MASTER_SITES, sanity checking URLs.");
		my @sites = split(/\s+/, $1);
		foreach my $i (@sites) {
			if ($i =~ m#^\w+://#) {
				if ($i !~ m#/$#) {
					log_error(NO_FILE, NO_LINE_NUMBER, "URL \"$i\" should ".
						"end with \"/\".");
				}
				if ($i =~ m#://[^/]*:/#) {
					log_error(NO_FILE, NO_LINE_NUMBER, "URL \"$i\" contains ".
						"extra \":\".");
				}
				unless (&is_predefined($i)) {
					log_info(NO_FILE, NO_LINE_NUMBER, "URL \"$i\" ok.");
				}
			} else {
				log_info(NO_FILE, NO_LINE_NUMBER, "non-URL \"$i\" ok.");
			}
		if ($tmp =~ /\nDYNAMIC_MASTER_SITES[+?]?=/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "MASTER_SITES and DYNAMIC_MASTER_SITES ".
				"found. Is this ok?");
			}
		}
	} elsif ($tmp !~ /\nDYNAMIC_MASTER_SITES[+?]?=/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "no MASTER_SITES or DYNAMIC_MASTER_SITES found. ".
			"Is this ok?");
	}

	# check DISTFILES and related items.
	$distname = $1 if ($tmp =~ /\nDISTNAME[+?]?=[ \t]*([^\n]+)\n/);
	$pkgname = $1 if ($tmp =~ /\nPKGNAME[+?]?=[ \t]*([^\n]+)\n/);
	$svrpkgname = $1 if ($tmp =~ /\nSVR4_PKGNAME[+?]?=[ \t]*([^\n]+)\n/);
	$extractsufx = $1 if ($tmp =~ /\nEXTRACT_SUFX[+?]?=[ \t]*([^\n]+)\n/);
	$distfiles = $1 if ($tmp =~ /\nDISTFILES[+?]?=[ \t]*([^\n]+)\n/);

	# check bogus EXTRACT_SUFX.
	if ($extractsufx ne '') {
		log_info(NO_FILE, NO_LINE_NUMBER, "seen EXTRACT_SUFX, checking value.");
		if ($distfiles ne '' && ($extractsufx eq '.tar.gz')) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "no need to define EXTRACT_SUFX if ".
				"DISTFILES is defined.");
		}
		if ($extractsufx eq '.tar.gz') {
			log_warning(NO_FILE, NO_LINE_NUMBER, "EXTRACT_SUFX is \".tar.gz.\" ".
				"by default. you don't need to specify it.");
		}
	} else {
		log_info(NO_FILE, NO_LINE_NUMBER, "no EXTRACT_SUFX seen, using default value.");
		$extractsufx = '.tar.gz';
	}

	log_info(NO_FILE, NO_LINE_NUMBER, "sanity checking PKGNAME.");
	if ($pkgname ne '' && $pkgname eq $distname) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "PKGNAME is \${DISTNAME} by default, ".
			"you don't need to define PKGNAME.");
	}
	if ($svrpkgname ne '') {
		if (length($svrpkgname) > 5) {
			log_error(NO_FILE, NO_LINE_NUMBER, "SVR4_PKGNAME should not be longer ".
				"than 5 characters.");
		}
	}
	$i = ($pkgname eq '') ? $distname : $pkgname;
	$i =~ s/\${DISTNAME[^}]*}/$distname/g;
	if ($i =~ /-([^-]+)$/) {
		my ($j, $k) = ($`, $1);
		if ($j =~ /[0-9]$/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "is \"$j\" sane as package name ".
				"WITHOUT version number? ".
				"if not, avoid \"-\" in version number ".
				"part of ".
				(($pkgname eq '') ? "DISTNAME." : "PKGNAME."));
		}
		# Be very smart. Kids, don't do this at home.
		if ($k =~ /\$(\(|\{)([A-Z_-]+)(\)|\})/) {
			my $k1 = $2;
			$k = $1 if ($rawwhole =~ /\n$k1[ \t]*?=[ \t]*([^\n]+)\n/);
		}
		if ($k =~ /^pl[0-9]*$/
		 || $k =~ /^[0-9]*[A-Za-z]*[0-9]*(\.[0-9]*[A-Za-z]*[0-9]*)*$/) {
			log_info(NO_FILE, NO_LINE_NUMBER, "trailing part of PKGNAME\"-$k\" ".
				"looks fine.");
		} else {
			log_error(NO_FILE, NO_LINE_NUMBER, "version number part of PKGNAME".
				(($pkgname eq '')
					? ', which is derived from DISTNAME, '
					: ' ').
				"looks illegal. You should modify \"-$k\"");
		}
	} else {
		log_error(NO_FILE, NO_LINE_NUMBER, "PKGNAME".
			(($pkgname eq '')
				? ', which is derived from DISTNAME, '
				: ' ').
			"must come with version number, like \"foobaa-1.0\".");
		if ($i =~ /_pl[0-9]*$/
		 || $i =~ /_[0-9]*[A-Za-z]?[0-9]*(\.[0-9]*[A-Za-z]?[0-9]*)*$/) {
			log_error(NO_FILE, NO_LINE_NUMBER, "you seem to be using underline ".
				"before version number in PKGNAME. ".
				"it has to be hyphen.");
		}
	}
	if ($distname =~ /(nb\d*)/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "is '$1' really ok on DISTNAME, ".
				"or is it intended for PKGNAME?");
	}

	# if DISTFILES have only single item, it is better to avoid DISTFILES
	# and to use combination of DISTNAME and EXTRACT_SUFX.
	# example:
	#	DISTFILES=package-1.0.tgz
	# should be
	#	DISTNAME=     package-1.0
	#	EXTRACT_SUFX= .tgz
	if ($distfiles =~ /^\S+$/) {
		$bogusdistfiles++;
		log_info(NO_FILE, NO_LINE_NUMBER, "seen DISTFILES with single item, checking value.");
		log_warning(NO_FILE, NO_LINE_NUMBER, "use of DISTFILES with single file ".
			"discouraged. distribution filename should be set by ".
			"DISTNAME and EXTRACT_SUFX.");
		if ($distfiles eq $distname . $extractsufx) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "definition of DISTFILES not necessary. ".
				"DISTFILES is \${DISTNAME}/\${EXTRACT_SUFX} ".
				"by default.");
		}

		# make an advice only in certain cases.
		if ($pkgname ne '' && $distfiles =~ /^$pkgname([-\.].+)$/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "how about \"DISTNAME=$pkgname\"".
				(($1 eq '.tar.gz')
					? ""
					: " and \"EXTRACT_SUFX=$1\"").
				", instead of DISTFILES?");
		}
	}

	# additional checks for committer.
	$i = ($pkgname eq '') ? $distname : $pkgname;
	if ($opt_committer && -f "$opt_packagedir/$i.tgz") {
		log_warning(NO_FILE, NO_LINE_NUMBER, "be sure to remove $opt_packagedir/$i.tgz ".
			"before committing the package.");
	}

	push(@varnames, split(/\s+/, <<EOF));
DISTNAME PKGNAME SVR4_PKGNAME CATEGORIES MASTER_SITES MASTER_SITE_SUBDIR
EXTRACT_SUFX DISTFILES
EOF

	#
	# section 3: PATCH_SITES/PATCHFILES(optional)
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking second section of $file, (PATCH*: optional).");
	$tmp = $sections[$idx];

	if ($tmp =~ /(PATCH_SITES|PATCH_SITE_SUBDIR|PATCHFILES|PATCH_DIST_STRIP)/) {
		&checkearlier($tmp, @varnames);

                $tmp = "\n$tmp";

		if ($tmp =~ /\n(PATCH_SITES)=/) {
			log_info(NO_FILE, NO_LINE_NUMBER, "seen PATCH_SITES.");
			$tmp =~ s/$1[^\n]+\n//;
		}
		if ($tmp =~ /\n(PATCH_SITE_SUBDIR)=/) {
			log_info(NO_FILE, NO_LINE_NUMBER, "seen PATCH_SITE_SUBDIR.");
			$tmp =~ s/$1[^\n]+\n//;
		}
		if ($tmp =~ /\n(PATCHFILES)=/) {
			log_info(NO_FILE, NO_LINE_NUMBER, "seen PATCHFILES.");
			$tmp =~ s/$1[^\n]+\n//;
		}
		if ($tmp =~ /\n(PATCH_DIST_ARGS)=/) {
			log_info(NO_FILE, NO_LINE_NUMBER, "seen PATCH_DIST_ARGS.");
			$tmp =~ s/$1[^\n]+\n//;
		}
		if ($tmp =~ /\n(PATCH_DIST_STRIP)=/) {
			log_info(NO_FILE, NO_LINE_NUMBER, "seen PATCH_DIST_STRIP.");
			$tmp =~ s/$1[^\n]+\n//;
		}

		&checkextra($tmp, 'PATCH_SITES');

		$idx++;
	}

	push(@varnames, split(/\s+/, <<EOF));
PATCH_SITES PATCHFILES PATCH_DIST_STRIP
EOF

	#
	# section 4: MAINTAINER
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking third section of $file (MAINTAINER).");
	$tmp = $sections[$idx++];

	# check the order of items.
        my @tocheck=split(/\s+/, <<EOF);
MAINTAINER HOMEPAGE COMMENT
EOF

        &checkorder('MAINTAINER', $tmp, @tocheck);

	# warnings for missing or incorrect HOMEPAGE
	$tmp = "\n" . $tmp;
	if ($tmp !~ /\nHOMEPAGE[+?]?=[ \t]*([^\n]*)\n/ || $1 =~ /^[ \t]*$/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "please add HOMEPAGE if the package has one.");
	} else {
		$i = $1;
		if ($i =~ m#^\w+://#) {
			if ($i !~ m#^\w+://[^\n/]+/#) {
				log_warning(NO_FILE, NO_LINE_NUMBER, "URL \"$i\" does not ".
						"end with \"/\".");
			}
		}
	}

	# warnings for missing COMMENT
	if ($tmp !~ /\nCOMMENT=\s*(.*)$/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "please add a short COMMENT describing the package.");
	} else {
		# and its properties:
		my $tmp2 = $1;
		if ($tmp2 =~ /\.$/i) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "COMMENT should not end with a '.' (period).");
		}
		if ($tmp2 =~ /^(a|an) /i) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "COMMENT should not begin with '$1 '.");
		}
		if ($tmp2 =~ /^[a-z]/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "COMMENT should start with a capital letter.");
		}
		if (length($tmp2) > 70) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "COMMENT should not be longer than 70 characters.");
		}
	}

	checkearlier($tmp, @varnames);
	$tmp = "\n" . $tmp;
	if ($tmp =~ /\nMAINTAINER=[^@]+\@netbsd.org/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "\@netbsd.org should be \@NetBSD.org in MAINTAINER.");
	} elsif ($tmp =~ /\nMAINTAINER=[^\n]+/) {
		$tmp =~ s/\nMAINTAINER=[^\n]+//;
	} else {
		log_error(NO_FILE, NO_LINE_NUMBER, "no MAINTAINER listed in $file.");
                # Why is this fatal? There's a default in bsd.pkg.mk - HF
	}
	$tmp =~ s/\n\n+/\n/g;

	push(@varnames, split(/\s+/, <<EOF));
MAINTAINER HOMEPAGE COMMENT
EOF

	#
	# section 5: *_DEPENDS (may not be there)
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking fourth section of $file(*_DEPENDS).");
	$tmp = $sections[$idx];

	my @linestocheck = split(/\s+/, <<EOF);
BUILD_USES_MSGFMT BUILD_DEPENDS DEPENDS
EOF
        if ($tmp =~ /(DEPENDS_TARGET|FETCH_DEPENDS|LIB_DEPENDS|RUN_DEPENDS).*=/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "$1 is deprecated, please use DEPENDS.");
	}
	if ($tmp =~ /(LIB_|BUILD_|RUN_|FETCH_)?DEPENDS/ or
	    $tmp =~ /BUILD_USES_MSGFMT/) {
		&checkearlier($tmp, @varnames);

		if (!defined $ENV{'PORTSDIR'}) {
			$ENV{'PORTSDIR'} = $conf_portsdir;
		}
		foreach my $i (grep(/^[A-Z_]*DEPENDS[?+]?=/, split(/\n/, $tmp))) {
			$i =~ s/^([A-Z_]*DEPENDS)[?+]?=[ \t]*//;
			my $j = $1;
			log_info(NO_FILE, NO_LINE_NUMBER, "checking packages listed in $j.");
			foreach my $k (split(/\s+/, $i)) {
				my $l = (split(':', $k))[0];

				# check BUILD_USES_MSGFMT
				if ($l =~ /^(msgfmt|gettext)$/) {
					log_warning(NO_FILE, NO_LINE_NUMBER, "dependency to $1 ".
						"listed in $j. Consider using".
						" BUILD_USES_MSGFMT.");
				}
				# check USE_PERL5
				if ($l =~ /^perl(\.\d+)?$/) {
					log_warning(NO_FILE, NO_LINE_NUMBER, "dependency to perl ".
						"listed in $j. Consider using".
						" USE_PERL5.");
				}

				# check USE_GMAKE
				if ($l =~ /^(gmake|\${GMAKE})$/) {
					log_warning(NO_FILE, NO_LINE_NUMBER, "dependency to $1 ".
						"listed in $j. Consider using".
						" USE_GMAKE.");
				}

				# check direct dependencies on -dirs packages
				if ($l =~ /^([-a-zA-Z0-9]+)-dirs[-><=]+(.*)/) {
					log_warning(NO_FILE, NO_LINE_NUMBER, "dependency to $1-dirs ".
						"listed in $j. Consider using".
						" USE_DIRS+=$1-$2.");
				}

				# check pkg dir existence
				my @m = split(/:/, $k);
				if ($#m >= 1) {
					$m[1] =~ s/\${PKGSRCDIR}/$ENV{'PKGSRCDIR'}/;
					if (! -d "$opt_packagedir/$m[1]") {
						log_warning(NO_FILE, NO_LINE_NUMBER, "no package directory $m[1] found, even though it is listed in $j.");
					} else {
						log_info(NO_FILE, NO_LINE_NUMBER, "package directory $m[1] found.");
					}
				} else {
					log_error(NO_FILE, NO_LINE_NUMBER, "invalid package dependency specification \"$k\".");
				}
			}
		}
		foreach my $i (@linestocheck) {
			$tmp =~ s/$i[?+]?=[^\n]+\n//g;
		}

		&checkextra($tmp, '*_DEPENDS');

		$idx++;
	}

	push(@varnames, @linestocheck);
	&checkearlier($tmp, @varnames);

	#
	# Makefile 6: check the rest of file
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking the rest of the $file.");
	$tmp = join("\n\n", @sections[$idx .. scalar(@sections)-1]);

	$tmp = "\n" . $tmp;	# to make the begin-of-line check easier

	&checkearlier($tmp, @varnames);

	# check WRKSRC/NO_WRKSUBDIR
	#
	# do not use DISTFILES/DISTNAME to control over WRKSRC.
	# DISTNAME is for controlling distribution filename.
	# example:
	#	DISTNAME= package
	#	PKGNAME=  package-1.0
	#	DISTFILES=package-1.0.tgz
	# should be
	#	DISTNAME=    package-1.0
	#	EXTRACT_SUFX=.tgz
	#	WRKSRC=      ${WRKDIR}/package
	#
	log_info(NO_FILE, NO_LINE_NUMBER, "checking WRKSRC.");
	$wrksrc = $nowrksubdir = '';
	$wrksrc = $1 if ($tmp =~ /\nWRKSRC[+?]?=[ \t]*([^\n]*)\n/);
	$nowrksubdir = $1 if ($tmp =~ /\nNO_WRKSUBDIR[+?]?=[ \t]*([^\n]*)\n/);
	if ($nowrksubdir eq '') {
		$realwrksrc = $wrksrc ? "$wrksrc/$distname"
				      : "\${WRKDIR}/$distname";
	} else {
		$realwrksrc = $wrksrc ? $wrksrc : '${WRKDIR}';
	}
	log_info(NO_FILE, NO_LINE_NUMBER, "WRKSRC seems to be $realwrksrc.");

	if ($nowrksubdir eq '') {
		log_info(NO_FILE, NO_LINE_NUMBER, "no NO_WRKSUBDIR, checking value of WRKSRC.");
		if ($wrksrc eq 'work' || $wrksrc =~ /^$[\{\(]WRKDIR[\}\)]/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "WRKSRC is set to meaningless value ".
				"\"$1\".".
				($nowrksubdir eq ''
					? " use \"NO_WRKSUBDIR=yes\" instead."
					: ""));
		}
		if ($bogusdistfiles) {
			if ($distname ne '' && $wrksrc eq '') {
			    log_warning(NO_FILE, NO_LINE_NUMBER, "do not use DISTFILES and DISTNAME ".
				"to control WRKSRC. how about ".
				"\"WRKSRC=\${WRKDIR}/$distname\"?");
			} else {
			    log_warning(NO_FILE, NO_LINE_NUMBER, "DISTFILES/DISTNAME affects WRKSRC. ".
				"Use caution when changing them.");
			}
		}
	} else {
		log_info(NO_FILE, NO_LINE_NUMBER, "seen NO_WRKSUBDIR, checking value of WRKSRC.");
		if ($wrksrc eq 'work' || $wrksrc =~ /^$[\{\(]WRKDIR[\}\)]/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "definition of WRKSRC not necessary. ".
				"WRKSRC is \${WRKDIR} by default.");
		}
	}

	foreach my $i (grep(/^(\W+_ENV)[?+]?=/, split(/\n/, $tmp))) {
		$i =~ s/^(\W+_ENV)[?+]?=[ \t]*//;
		my $j = $1;
		foreach my $k (split(/\s+/, $i)) {
			if ($k !~/^".*"$/ && $k =~ /\${/ && $k !~/:Q}/) {
				log_warning(NO_FILE, NO_LINE_NUMBER, "definition of $k in $j. ".
				"should use :Q or be quoted.");
			}
		}
	}

	# check USE_X11 and USE_IMAKE
	if ($tmp =~ /\nUSE_IMAKE[?+]?=/ && $tmp =~ /\nUSE_X11[?+]?=/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "since you already have USE_IMAKE, ".
			"you don't need USE_X11.");
	}

	# check direct use of important make targets.
	if ($tmp =~ /\n(fetch|extract|patch|configure|build|install):/) {
		log_error(NO_FILE, NO_LINE_NUMBER, "direct redefinition of make target \"$1\" ".
			"discouraged. redefine \"do-$1\" instead.");
	}

	return true;
}

sub checkextra($$) {
	my ($str, $section) = @_;

	$str = "\n" . $str if ($str !~ /^\n/);
	$str =~ s/\n#[^\n]*/\n/g;
	$str =~ s/\n\n+/\n/g;
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	return if ($str eq '');

	if ($str =~ /^([\w\d]+)/) {
		log_warning(NO_FILE, NO_LINE_NUMBER, "extra item placed in the ".
			"$section section, ".
			"for example, \"$1\".");
	} else {
		log_warning(NO_FILE, NO_LINE_NUMBER, "extra item placed in the ".
			"$section section.");
	}
}

sub checkorder($$@) {
	my ($section, $str, @order) = @_;

	log_info(NO_FILE, NO_LINE_NUMBER, "checking the order of $section section.");

	my @items = ();
	foreach my $i (split("\n", $str)) {
		$i =~ s/[+?]?=.*$//;
		push(@items, $i);
	}

	@items = reverse(@items);
	my $j = -1;
	my $invalidorder = 0;
	while (scalar(@items)) {
		my $i = pop(@items);
		my $k = 0;
		while ($k < scalar(@order) && $order[$k] ne $i) {
			$k++;
		}
		if ($k <= $#order) {
			if ($k < $j) {
				log_error(NO_FILE, NO_LINE_NUMBER, "$i appears out-of-order.");
				$invalidorder++;
			} else {
				log_info(NO_FILE, NO_LINE_NUMBER, "seen $i, in order.");
			}
			$j = $k;
		} else {
			log_error(NO_FILE, NO_LINE_NUMBER, "extra item \"$i\" placed in".
				" the $section section.");
		}
	}
	if ($invalidorder) {
		log_error(NO_FILE, NO_LINE_NUMBER, "order must be " . join('/', @order) . '.');
	} else {
		log_info(NO_FILE, NO_LINE_NUMBER, "$section section is ordered properly.");
	}
}

sub checkearlier($@) {
	my ($str, @varnames) = @_;

	log_info(NO_FILE, NO_LINE_NUMBER, "checking items that have to appear earlier.");
	foreach my $i (@varnames) {
		if ($str =~ /\n$i[?+]?=/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "\"$i\" has to appear earlier.");
		}
	}
}

sub abspathname($$) {
	my ($str, $file) = @_;
	my ($s, $i, $pre, %cmdnames);

	# ignore parameter string to echo command
	$str =~ s/[ \t][\@-]?(echo|\$[\{\(]ECHO[\}\)]|\$[\{\(]ECHO_MSG[\}\)])[ \t]+("(\\'|\\"|[^"])*"|'(\\'|\\"|[^"])*')[ \t]*[;\n]//;

	log_info(NO_FILE, NO_LINE_NUMBER, "checking direct use of full pathnames in $file.");
	foreach my $s (split(/\n+/, $str)) {
		$i = '';
		if ($s =~ /(^|[ \t\@'"-])(\/[\w\d])/) {
			# suspected pathnames are recorded.
			$i = $2 . $';
			$pre = $` . $1;

			if ($pre =~ /MASTER_SITE_SUBDIR/) {
				# MASTER_SITE_SUBDIR lines are ok.
				$i = '';
			}
		}
		if ($i ne '') {
			$i =~ s/\s.*$//;
			$i =~ s/['"].*$//;
			if ($opt_warn_absname) {
				log_warning($file, NO_LINE_NUMBER, "possible use of absolute pathname \"$i\".");
			}
		}
	}

	log_info(NO_FILE, NO_LINE_NUMBER, "checking direct use of pathnames, phase 1.");
	my %abspathnames = split(/\n|\t+/, <<EOF);
/usr/opt	\${PORTSDIR} instead
$conf_portsdir	\${PORTSDIR} instead
$conf_localbase	\${PREFIX} or \${LOCALBASE}, as appropriate
/usr/X11	\${PREFIX} or \${X11BASE}, as appropriate
/usr/X11R6	\${PREFIX} or \${X11BASE}, as appropriate
EOF
	foreach my $i (keys %abspathnames) {
		if ($str =~ /$i/) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "possible direct use of \"$&\" ".
				"found in $file. if so, use $abspathnames{$i}.");
		}
	}

	log_info(NO_FILE, NO_LINE_NUMBER, "checking direct use of pathnames, phase 2.");
	my %relpathnames = split(/\n|\t+/, <<EOF);
distfiles	\${DISTDIR} instead
pkg		\${PKGDIR} instead
files		\${FILESDIR} instead
scripts		\${SCRIPTDIR} instead
patches		\${PATCHDIR} instead
work		\${WRKDIR} instead
EOF
	foreach my $i (keys %relpathnames) {
		if ($str =~ /(\.\/|\$[\{\(]\.CURDIR[\}\)]\/|[ \t])(\b$i)\//) {
			log_warning(NO_FILE, NO_LINE_NUMBER, "possible direct use of \"$i\" ".
				"found in $file. if so, use $relpathnames{$i}.");
		}
	}
	return true;
}

sub is_predefined($) {
	my ($url) = @_;
	my ($site, $subdir);

	if ($site = (grep($url =~ $_, keys %predefined))[0]) {
		$url =~ /$site/;
		$subdir = $';
		$subdir =~ s/\/$//;
		log_warning(NO_FILE, NO_LINE_NUMBER, "how about using ".
			"\${MASTER_SITE_$predefined{$site}:=$subdir/} instead of \"$url\?");
		return true;
	}
	return false;
}

sub category_check() {
	my ($file) = "Makefile";
	my ($fname) = ("$opt_packagedir/$file");
	my ($lines);
	my (@makefile_subdirs) = ();
	my (@filesys_subdirs) = ();

	if (!defined($lines = load_file($fname))) {
		log_error($fname, NO_LINE_NUMBER, "error while reading.");
		return false;
	}
	if (scalar(@$lines) == 0) {
		log_error($file, NO_LINE_NUMBER, "may not be empty.");
		return true;
	}
	if ($lines->[0]->text =~ qr"^# $regex_rcsidstr$") {
		log_info($lines->[0]->file, $lines->[0]->lineno, "RCS Id tag found.");
	} elsif (scalar(@$lines) > 1 && $lines->[1]->text =~ qr"^# $regex_rcsidstr$") {
		log_info($lines->[1]->file, $lines->[1]->lineno, "RCS Id tag found.");
	} else {
		log_error($file, NO_LINE_NUMBER, "No RCS Id tag found.");
	}

	@filesys_subdirs = grep { ($_ = substr($_, 0, -1)) ne "CVS"; } glob("*/");
	
	my ($first, $last_subdir, $comment_seen) = (true, undef, false);
	foreach my $line (@$lines) {
		if ($line->text =~ qr"^(#?)SUBDIR(.*?)=\s*(\S+)\s*(?:#\s*(.*?)\s*|)$") {
			my ($comment_flag, $operator, $subdir, $comment) = ($1, $2, $3, $4);
			if ($comment_flag eq "#") {
				if (defined($comment) && $comment eq "") {
					log_warning($line->file, $line->lineno, "$subdir commented out without giving a reason.");
				}
				push(@makefile_subdirs, $subdir);
			} elsif ($first) {
				$first = false;
				if ($operator ne "" && $operator ne "+") {
					log_error($line->file, $line->lineno, "SUBDIR= or SUBDIR+= expected.");
				}
				push(@makefile_subdirs, $subdir);
				$last_subdir = $subdir;
			} else {
				if ($operator ne "+") {
					log_error($line->file, $line->lineno, "SUBDIR+= expected.");
				}
				push(@makefile_subdirs, $subdir);
				if ($last_subdir ge $subdir) {
					log_error($line->file, $line->lineno, "$subdir should come before $last_subdir.");
				}
				$last_subdir = $subdir;
			}
		} elsif ($line->text =~ qr"^COMMENT\s*=\s*([^#]*?)") {
			my ($comment) = ($1);
			$comment_seen = true;
		}
	}

	@filesys_subdirs = sort(@filesys_subdirs);
	@makefile_subdirs = sort(@makefile_subdirs);
	while (scalar(@filesys_subdirs) > 0 || scalar(@makefile_subdirs) > 0) {
		my ($f, $m) = ($filesys_subdirs[0] || "", $makefile_subdirs[0] || "");
		if ($f eq $m) {
			shift(@filesys_subdirs);
			shift(@makefile_subdirs);
		} elsif ($m eq "" || $f lt $m) {
			log_error($file, NO_LINE_NUMBER, "$f exists in the file system, but not in the Makefile.");
			shift(@filesys_subdirs);
		} else {
			log_error($file, NO_LINE_NUMBER, "$m exists in the Makefile, but not in the file system.");
			shift(@makefile_subdirs);
		}
	}

	if (!$comment_seen) {
		log_error($file, NO_LINE_NUMBER, "no COMMENT line found.");
	}
	return true;
}

#
# The main program
#

main();
