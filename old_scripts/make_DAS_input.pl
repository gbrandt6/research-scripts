#!/usr/bin/perl -w
use strict;
use Getopt::Long;

#this script takes a binning fasta file and outputs a tab separated file of contig to bin identifier

#getopts files
my $bin_input_file;
my $bin_id;
my $output_file="out.tsv";
my $help=0;

#global variables
my @bin_lines;
my @output;

sub usage {
  print "\nHow to run this code:\n";
  print "./make_DAS_input.pl -i [bin - fasta format] -b [bin_identifier] -o [output file name]\n";
  print "Where the binning input file is a fasta file representing a group of contigs in one bin\n";
  print "Where the bin identifier is a unique identity for each bin\n";
  print "Where the output file name is the name of the output file\n";
  print "Use -h to get this message\n\n";
}

sub initialize {
  GetOptions(
    'i=s' => \$bin_input_file,
    'b=s' => \$bin_id,
    'o=s' => \$output_file,
    'h'   => \$help,
  ) or die "Incorrect usage!\n";

  #check to see if the help message was activated
  if ($help ne 0) { usage(); exit 1;}
  #check for the mandatory input files
  unless (defined $bin_input_file) { print "You need to enter the input file\n";
    usage(); exit 1; }
  unless (defined $bin_id) { $bin_id=$bin_input_file; }
  if ($output_file eq "out.tsv") {print "You need to name your output file\n";
    usage(); exit 1;}
}
sub openFile{
  my ($filename) = @_;
  my @return;
  open (FILE, "<", $filename) or die "Can't open the file $filename!!!!\n";
  while (<FILE>) {
    chomp $_;
    push @return, $_;
  }
  close FILE;
  return @return;
}
sub readLines{
  my (@lines) = @_;
  my $file_length = scalar @lines;
  for (my $i=0; $i < $file_length; $i++) {
    my $result = doFunction($lines[$i]);
    if ($result ne "none") {
      my $newresult = substr $result, 1;
      push @output, $newresult;
    }
  }
}

sub doFunction{
  my ($line) = @_;
  if ($line =~ m/^>/) {
    return $line;
  }
  else {
    return "none";
  }
}

sub printOutput{
  my ($filename) = @_;
  open (OUT, ">", $filename) or die "Can't open output file $filename!!!\n";
  my $filelength = scalar @output;
  for (my $i=0; $i < $filelength; $i++) {
    my $line = getLine($output[$i]);
    print OUT $line, "\n";
  }
  close OUT;
}

sub getLine{
  my ($line) = @_;
  my $return = $line . "\t" . $bin_id;
  return $return;
}

initialize();
@bin_lines = openFile($bin_input_file);
readLines(@bin_lines);
printOutput($output_file);
