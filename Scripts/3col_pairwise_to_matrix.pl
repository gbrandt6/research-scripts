#!/usr/bin/perl -w
use strict;

sub usage{
  print "How to run this code:\n";
  print "3col_pairwise_to_matrix.pl dist_table > dist_matrix\n";
}

#check to see if the arguments are there
if (scalar @ARGV < 1) {
    usage();
    exit 1;
}

#initialize the arguments
my $infile = $ARGV[0];

open (IN, "<", $infile) or die "Can't read input file!!\n";

#go through the input file
my @values; my $name1; my $name2; my $MASH;
my %distances;
my %unique_names;

while (<IN>) {
  chomp $_;
  @values = split /\t/, $_;
  $name1 = $values[0];
  $name2 = $values[1];
  $MASH = $values[2];
  $distances{$name1,$name2} = $MASH;
  unless (exists $unique_names{$name1}) {
    $unique_names{$name1} = 1;
  }
}

close IN;

#get the list
my @names;
foreach my $name (sort keys %unique_names) {
  push @names, $name;
}

my $size = scalar @names;
#make first line of hash
print "MASH distances\t";
for (my $i=0; $i < $size; $i++) {
  print "$names[$i]\t";
}
print "\n";
for (my $i=0; $i < $size; $i++) {
  my $name1 = $names[$i];
  print "$name1\t";
  for (my $j=0; $j < $size; $j++) {
    $name2 = $names[$j];
    print $distances{$name1,$name2};
    print "\t";
  }
  print "\n";
}
