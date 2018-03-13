#!/usr/bin/perl -w
use strict;

#check to see if the arguments are there
if (scalar @ARGV < 1) {
    usage();
    exit 1;
}

#initialize the arguments
my $infile = $ARGV[0];
my $limit = $ARGV[1];
my $outfile = $ARGV[2];

#open the files
open (IN, "<", $infile) or die "Can't read input file!!\n";

#go through the input file and add to array
my @lines;
while (<IN>) {
    chomp $_;
    push @lines, $_;
}
close IN;

#open the output file
open (OUT, ">", $outfile) or die "Can't read the output file!!!\n";

#look for a new sequence
my $length = scalar @lines;
my $line;
my $i = 0;
while ($i < $length) {
    $line = $lines[$i];
    if ($line =~ /^>.*$/) {
	my $result = calculate_length($lines[$i+1], $limit);
	if ($result == 1) {
	    print OUT $line, "\n";
	    print OUT $lines[$i+1], "\n";
	    print OUT "\n";
	}
	$i++;
    }
    $i++;
}

#close files
close OUT;

sub calculate_length {
    my ($sequence, $limit) = @_;
    my $length = length $sequence;
    my $result;
    if ($length >= $limit) {
	$result = 1;
    }
    else {
	$result = 0;
    }
    return $result;
}

sub usage {
    print "How to run this code:\n";
    print "FastA.filter.length.pl input.file length output.file.name\n";
    print "input file must be in fasta format\n";
}

