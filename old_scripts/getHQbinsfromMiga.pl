#!/usr/bin/perl -w
use strict;

$#ARGV>=0 or die "
Usage:
    $0 lofiles... > outfile.tsv
    logfile File from migaproject/daemon/stats/
    The output file will have the file names in the first column
    And summary information about the genome in all other columns
";

#header line
print "Genome name\tContigs\tN50 (bp)\tTotal length (bp)\tG+C content (%)\tPredicted proteins\tAverage length (aa)\tCoding density (%)\tCompleteness (%)\tContamination (%)\tQuality\tScore\n"; #printing 12 things

for my $fa (@ARGV){
  open FA, "<", $fa or die "Cannot open file: $fa: $!\n";

  (my $name = $fa) =~ s/.log//g; #sample ID
  print $name, "\t"; #print 1

  my $var; #variable representing values

  while (<FA>) { #open file
    my $line = $_;
    chomp $line;

    if ($line =~ m/Contigs/) {
      ($var = $line) =~ s/Contigs://g;
      $var =~ s/\s+//g;
      $var =~ s/\.//g;
      print $var, "\t";} # print 2

    elsif ($line =~ m/N50/) {
      ($var = $line) =~ s/N50://g;
      $var =~ s/\s+//g;
      $var =~ s/\.//g;
      $var =~ s/bp$//g;
      print $var, "\t";} # print 3

    elsif ($line =~ m/Total/) {
      ($var = $line) =~ s/Total length://g;
      $var =~ s/\s+//g;
      $var =~ s/\.//g;
      $var =~ s/bp$//g;
      print $var, "\t";} # print 4

    elsif ($line =~ m/content/) {
      ($var = $line) =~ s/[A-Za-z]*//g;
      $var =~ s/[:+]*//g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      $var =~ s/\%$//g;
      print $var, "\t";} # print 5

    elsif ($line =~ m/proteins/) {
      ($var = $line) =~ s/Predicted proteins://g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      print $var, "\t";} # print 6

    elsif ($line =~ m/Average/) {
      ($var = $line) =~ s/Average length://g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      $var =~ s/aa$//g;
      print $var, "\t";} # print 7

    elsif ($line =~ m/Coding/) {
      ($var = $line) =~ s/Coding density://g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      $var =~ s/\%$//g;
      print $var, "\t";} # print 8

    elsif ($line =~ m/Completeness/) {
      ($var = $line) =~ s/Completeness://g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      $var =~ s/\%$//g;
      print $var, "\t";} # print 9

    elsif ($line =~ m/Contamination/) {
      ($var = $line) =~ s/Contamination://g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      $var =~ s/\%$//g;
      print $var, "\t";} # print 10

    elsif ($line =~ m/Quality/) {
      ($var = $line) =~ s/Quality://g;
      $var =~ s/\s+//g;
      $var =~ s/\.$//g;
      print $var, "\t";} # print 11
  }

  my $quality; #quality score
  if ($var >= 50) {
    $quality = "High";
  }
  elsif ($var >= 25) {
    $quality = "Intermediate";
  }
  else {
    $quality = "Low";
  }

  print $quality, "\n";

  close FA;
}
