#!/usr/bin/perl -w
use strict;

#check to see if the arguments are there
if (scalar @ARGV < 1) {
    usage();
    exit 1;
}

#initialize the arguments
my $infile = $ARGV[0];
my $outfile = $ARGV[1];

#open the files
open (IN, "<", $infile) or die "Can't read input file!!\n";

#go through the input file and add to array
my @lines;
while (<IN>) {
    chomp $_;
    push @lines, $_;
}
close IN;

my $sum = 0;
my $total = 0;
my $length = scalar @lines;
for (my $i=0; $i < $length; $i++) {
  my @fields = split(/\t/, $lines[$i]);
  $sum += $fields[1];
  $total += 1;
}

my $average = $sum / $total;

#open the output file
open (OUT, ">>", $outfile) or die "Can't read the output file!!!\n";

print OUT "Total contigs: ", $total, "\n";
print OUT "Average value: ", $average, "\n";

#close files
close OUT;

sub usage {
    print "This code finds the average value from the second column of a file\n";
    print "Perhaps for a file with GC content or Length per contig\n";
    print "How to run this code:\n";
    print "assembly.stats.avg.pl input.file output.file.name\n";
}
