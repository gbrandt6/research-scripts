#!/usr/bin/perl -w
use strict;
use Getopt::Long;


sub usage {
  print "\nHow to run this code:\n";
  print "./FastQ.length.pl -i [input fastq file] -o [optional output file, prints length of each sequence] > output.txt\n";
  print "This script gets the length of fastq sequences\n";
  print "Use -h to get this message\n\n";
}

#initializing getopts options
my $input;
my $output;
my $help=0;
my $OUT = 1;

sub initialize {
  GetOptions(
    'i=s' => \$input,
    'o=s' => \$output,
    'h'   => \$help,
  ) or die "Incorrect usage!!\n";

  #check for the help message
  if ($help ne 0) { usage(); exit 1;}
  #check for the mandatory input files
  unless (defined $input) {
    print "You need to enter the input file\n"; usage(); exit 1;
  }
  unless (defined $output) {
    $OUT = 0;
  }
}

initialize();
my $header;
my $seq;
my $counter=1;
my $length;
my $total_length;
my @headers;
my @lengths;

open (FILE, "<", $input) or die "Can't open the input file!!!\n";
while (<FILE>) {
  my $line = $_;
  chomp $line;

  #check for the line being the header
  if ($counter % 4 == 1) {
    $header = $line;
    $header =~ s/^@//g;
    $header =~ s/\s[^\s]//g;
    push @headers, $header;
  }
  elsif ($counter % 4 == 2) {
    $seq = $line;
    $length = length $seq;
    $total_length += $length;
    push @lengths, $length;
  }

  $counter++;
}

close FILE;
if ($OUT == 1) {
  open (FILEOUT, ">", $output) or die "Can't open the output file!!\n";
  my $size = scalar @headers;
  for (my $i=0; $i < $size; $i++) {
    print FILEOUT $headers[$i], "\t";
    print FILEOUT $lengths[$i], "\n";
  }
  close FILEOUT;
}

print "Total number of sequences:\t";
print scalar @headers, "\n";
print "Average sequence length:\t";
print $total_length / ($counter / 4), "\n";
print "Median sequence length:\t";
print $lengths[(($counter / 4) / 2)], "\n";
print "Total length of bp:\t\t";
print $total_length, "\n";
