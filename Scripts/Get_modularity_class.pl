#!/usr/bin/perl -w
use strict;

sub usage{
  print "How to run this code:\n";
  print "Get_modularity_class.pl ANI_nodes.csv ANI_edges.csv > output.csv \n";
}

#check to see if the arguments are there
if (scalar @ARGV < 2) {
    usage();
    exit 1;
}

#initialize the arguments
my $nodes = $ARGV[0];
my $edges = $ARGV[1];

#get the modularity classes
open (NODE, "<", $nodes) or die "Can't read node file!!\n";
my %classes;
while (<NODE>) {
  chomp $_;
  my @values = split(',', $_);
  my $id = $values[0];
  my $class = $values[7];
  $class =~ s/[^0-9]//g;
  $classes{$id} = $class;
}
close NODE;

#start printing file
print "Source,Target,Id,Weight,Modularity Class 1, Modularity Class 2\n";
#append to the edges file
#delete replicates
open (EDGE, "<", $edges) or die "Can't open edge file!!\n";
my %pairs;
my $start = 0;
while (<EDGE>) {
  chomp $_;
  unless ($start == 0) {
    my @values = split(',', $_);
    my $id1 = $values[0];
    my $id2 = $values[1];
    #delete replicates
    #check to see if the replicate is in the directory
    unless (exists $pairs{$id2} && $pairs{$id2} eq $id1) {
      my $class1 = $classes{$id1};
      my $class2 = $classes{$id2};
      my $num = substr($values[6], 0, 5);
      print "$id1,$id2,$num,$class1,$class2\n";
      $pairs{$id1} = $id2;
    }
  }
  $start = 1;
}
