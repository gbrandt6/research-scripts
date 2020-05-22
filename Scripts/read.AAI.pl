#!/usr/bin/perl -w
use strict;

$#ARGV>=0 or die "
    Usage: $0 input_file >> output_list.txt
    Input file is output from AAI comparison\n";

my $input_file = $ARGV[0];
my $aai_value;

open FILE, "<", $input_file or die "Cannot open input file: $input_file: $!\n";
my $marker = 1;
while (<FILE>) {
  if ($marker == 3) {
    #something
    my $line = $_;
    chomp $line;
    my @nums = $line =~ /\d+\.\d+/g;
    $aai_value = $nums[0];
  }
  $marker++;
}

my $name = $input_file;
my @names = $name =~ /pico\d+\.\d+/g;
my $name1 = $names[0];
my $name2 = $names [1];

if ($aai_value >= 90) {
  print "$name1\t$name2\t$aai_value\n";
}

close FILE;
