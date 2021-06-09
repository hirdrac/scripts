#!/usr/bin/perl -w
#
# clear_trailing_ws.pl - revision 4 (2019/8/21)
# Copyright(C) 2019 by Richard Bradley
#
# Removes trailing white space (end of line and trailing blank lines) and
# only overwrites original file with processed version if changes are made.
#

use strict;
use File::Copy;
use File::Temp qw(tempfile);
use LWP::MediaTypes qw(guess_media_type);


#### GLOBALS ####
# mime file types to be processed - all other file types are ignored
my %allowed =
  ("application/x-perl" => 1,
   "application/x-sh" => 1,
   "text/html" => 1,
   "text/plain" => 1,
   "text/x-c" => 1,
   "text/markdown" => 1);


#### FUNCTIONS ####
sub FixFile {
  my $fileName = shift;

  # Save fixed file to temp file
  my $fhIn;
  open($fhIn, "<", $fileName) || die "Can't read file '$fileName'\n";

  my ($fhOut, $tmpFile) = tempfile();

  my $changed = 0;
  my $blankLines = "";
  while (my $line = <$fhIn>) {
    # strip trailing white space from line
    my $originalLine = $line;
    $line =~ s/\s*\n$/\n/;
    if ($line ne $originalLine) {
      $changed = 1;
    }

    if ($line eq "\n") {
      # collect blank lines to remove extra at end of file
      $blankLines .= "\n";

    } else {
      print { $fhOut } $blankLines;
      $blankLines = "";
      print { $fhOut } "$line";
    }
  }

  close $fhOut;
  close $fhIn;

  if ($blankLines ne "") {
    # blank lines removed from end of file
    $changed = 1;
  }

  if ($changed) {
    # overwrite original file with temp version
    print "$fileName\n";
    move $tmpFile, $fileName;

  } else {
    # nothing changed, just kill the temp file
    unlink $tmpFile;
  }
}


#### MAIN ####
if (@ARGV <= 0) {
  print "Usage: $0 <file list>\n";
  print "Only files found to have trailing white space will be cleansed.\n";
  exit 0;
}

foreach my $i (@ARGV) {
  my $mt = guess_media_type($i);
  if (defined $allowed{$mt}) {
    FixFile $i;
  } else {
    print STDERR "$i: file type '$mt' not allowed\n";
  }
}
