#!/usr/bin/perl

use strict;
use File::Copy;

sub get_binaries($) {
    my $bin_dir = shift;
    $bin_dir =~ s!/$!!;
    opendir my $dir , $bin_dir || die "Cannot open directory $bin_dir";

    my @files;
    while(my $file = readdir($dir)) {
        my $full = "$bin_dir/$file";
        if (-f $full && -x $full) {
            push(@files, $full);
        }
    }
    closedir $dir;
    return @files;
}

sub libraries_for($) {
    my $full_path = shift;
    my %libs = ();
    my @lines = `ldd $full_path`;
    foreach my $line (@lines) {
        chomp($line);
        my @tokens = split(/=>/, $line);

        my $name = str_trim($tokens[0]);
        my $path = $name;
        if (@tokens > 1) {
            $path = $tokens[1];
        }
        $path = str_trim($path);
        $path =~ s!\s+.*!!;
        $name =~ s!\s+.*!!;
        if ($path =~ m!^/!) {
            $libs{$name} = $path;
        }
    }
    return %libs;
}

sub str_trim {
    my $line = $_[0];
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    return $line;
}

my $pg_bin_dir =  '/opt/postgres/bin';
my @binaries = get_binaries($pg_bin_dir);
my %libs = ();

foreach my $binary (@binaries) {
    my %bin_libs = libraries_for($binary);
    %libs = (%libs, %bin_libs);
}
my $dest_dir = '/opt/postgres-shared-libs';
mkdir($dest_dir) unless (-d $dest_dir);
foreach my $name (sort (keys %libs)) {
    my $path = $libs{$name};
    print("copying $path to $dest_dir\n");
    copy($path, $dest_dir) || die "Cannot copy $path to $dest_dir - $!\n";
}
