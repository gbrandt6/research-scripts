#!/usr/bin/perl -w
use strict;

$#ARGV>=0 or die "
Usage:
    $0 ANI_matrix.txt cutoff > ANI_matrix_cutoff.txt
    The ANI matrix is a table of genomes compared all vs all by ANI
";

#initialize the arguments
my $matrix = $ARGV[0];
my $cutoff = $ARGV[1];


open (IN, "<", $matrix) or die "Can't read matrix!!\n";
my $start = 0;
my @lines;
my $header;

while (<IN>) {
  chomp $_;
  push @lines, $_;
  print $lines[0];
  #my @lines = split(/\n/, $_);
  #print $lines[0];

  #if ($start == 0) {
  #  $header = $_;
  #  $start = 1;
  #}
  #else {
  #  push @lines, $_;
  #}
}
close IN;

#print $header, "\n";
#my $size = scalar @lines;
#for (my $i=0; $i < $size; $i++) {
#  my @values = split(/,/, $lines[$i]);
#  for (my $j=0; $j < scalar @values; $j++) {
    #print $values[$j];
#    if ($values[$j] == 0) {
      #print "0,";
      #print $values[$j], "\t";
#    }
#    elsif ($values[$j] < $cutoff) {
      #print "0,";
      #print $values[$j], "\t";
#    }
#    else  {
      #print $values[$i], ",";
#    }
#  }
  #print "\n";
#}
