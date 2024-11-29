#!/usr/bin/perl

use strict;
use File::Copy;

my $dest_dir = '/opt/emacs/shared-libs';
mkdir($dest_dir) unless (-d $dest_dir);
my @lines = `ldd /opt/emacs/bin/emacs`;
foreach my $line (@lines) {
    chomp($line);
    my @tokens = split(/=>/, $line);
    my $lib_name = str_trim($tokens[0]);
    if (@tokens > 1) {
        $lib_name = str_trim($tokens[1]);
    }
    $lib_name =~ s!\s+.*!!;
    if (-e $lib_name) {
        copy($lib_name, $dest_dir) || die "Cannot copy $lib_name to $dest_dir";
        print("$lib_name  =>  $dest_dir\n");
    }
}

sub str_trim {
    my $line = $_[0];
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    return $line;
}
